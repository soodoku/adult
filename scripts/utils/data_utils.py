import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf
try:
    from stargazer.stargazer import Stargazer
except:
    pass

def pandas_to_tex(df, texfile, index=False):
    if texfile.split(".")[-1] != ".tex":
        texfile += ".tex"

    tex_table = df.to_latex(index=index, header=False)
    tex_table_fragment = "\n".join(tex_table.split("\n")[2:-3])
    # Remove the last \\ in the tex fragment to prevent the annoying
    # "Misplaced \noalign" LaTeX error when I use \bottomrule
    tex_table_fragment = tex_table_fragment[:-2]

    with open(texfile, "w") as tf:
        tf.write(tex_table_fragment)
    return None


def tableone_to_texfrag(tableone, texfile):
    tex_table = tableone.tabulate(tablefmt="latex")
    # line #1 = \begin{tabular}...
    # line #2 = headers..
    # line #3 = \hline
    # last line = \end{tabular}
    # 2nd last line = \hline
    tex_table_fragment = "\n".join(tex_table.split("\n")[4:-2])
    # Remove the last \\ in the tex fragment to prevent the annoying
    # "Misplaced \noalign" LaTeX error when I use \bottomrule
    tex_table_fragment = tex_table_fragment[:-2]
    # Save
    if texfile.split(".")[-1] != ".tex":
        texfile += ".tex"
    with open(texfile, "w") as tf:
        tf.write(tex_table_fragment)
    return None


def fit_quantile_reg(y, x, quantile, df, z=None):
    if z is None:
        quantile_model = smf.quantreg(f"{y} ~ {x}", df)
    else:
        quantile_model = smf.quantreg(f"{y} ~ {x} + {z}", df)
    quantile_result = quantile_model.fit(q=quantile, max_iter=10_000)
    coef_list = [
        quantile,
        quantile_result.params["Intercept"],
        quantile_result.params[x],
        quantile_result.conf_int().loc[x][0],  # CI ll
        quantile_result.conf_int().loc[x][1],  # CI hl
        quantile_result.tvalues[x],
        quantile_result.pvalues[x],
        quantile_result.nobs,
    ]
    return coef_list


def fit_ols_reg(y, x, df, z=None):
    if z is None:
        ols_model = smf.ols(f"{y} ~ {x}", df)
    else:
        ols_model = smf.ols(f"{y} ~ {x} + {z}", df)
    ols_results = ols_model.fit()
    ols_ci = ols_results.conf_int().loc[x].tolist()
    ols_results = dict(
        intercept=ols_results.params["Intercept"],
        estimate=ols_results.params[x],
        ll=ols_results.conf_int().loc[x][0],  # CI ll
        hl=ols_results.conf_int().loc[x][1],  # CI hl
        tstat=ols_results.tvalues[x],
        pval=ols_results.pvalues[x],
        obs=ols_results.nobs,
    )
    return ols_results


def esttab_ols_quantile(y, x, quantiles, df, z=None, significant_digits=2):
    ## Set up regression models (quantile & OLS)
    if z is None:
        quantile_model = smf.quantreg(f"{y} ~ {x}", df)
        ols_model = smf.ols(f"{y} ~ {x}", df)
    else:
        quantile_model = smf.quantreg(f"{y} ~ {x} + {z}", df)
        ols_model = smf.ols(f"{y} ~ {x} + {z}", df)

    ## Fit and store estimates
    reg_results = []
    
    # Store OLS estimates
    reg_results.append(ols_model.fit(cov_type="HC3"))
    
    # Store quantile estimates
    for quantile in quantiles:
        result = quantile_model.fit(q=quantile, max_iter=10_000)
        reg_results.append(result)
    stargazer = Stargazer(reg_results)

    ## Edit stargazer table (absent variables seem to be ignored)
    coeflabels = {
        "rep": "Republican", 
        "C(gender)[T.2]": "Female",
        "C(educ2)[T.2]": "Educ (HS)",
        "C(educ2)[T.3]": "Educ (some coll.)",
        "C(educ2)[T.4]": "Educ (coll. grad.)",
        "age": "Age",
        "age2": "Age$^2$",        
        "C(race2)[T.2]": "Race (Black)",
        "C(race2)[T.3]": "Race (Hispanic)",
        "C(race2)[T.4]": "Race (Asian)",
        "C(race2)[T.5]": "Race (Other)",
        "C(region)[T.2]": "Region (MW)",
        "C(region)[T.3]": "Region (South)",
        "C(region)[T.4]": "Region (West)",
        "Intercept": "Constant", 
    }
    stargazer.rename_covariates(coeflabels)
    if z is None:
        stargazer.covariate_order(["rep", "Intercept"])
    else:
        stargazer.covariate_order(coeflabels.keys())
    stargazer.significant_digits(significant_digits)

    ## Pare down to get LaTeX *fragment*
    latex_str = stargazer.render_latex()
    latex_fragment_str = "\n".join(latex_str.split("\n")[8:-11])
    # Remove the last \\ in the tex fragment to prevent the annoying
    # "Misplaced \noalign" LaTeX error when I use \bottomrule
    latex_fragment_str = latex_fragment_str[:-2]  
    
    ## Make sig stars compatible with downstream dcolumns in LaTeX
    latex_fragment_str = latex_fragment_str.replace("$^{}$", "")
    latex_fragment_str = latex_fragment_str.replace("$^{*}$", "\sym{c}")
    latex_fragment_str = latex_fragment_str.replace("$^{**}$", "\sym{b}")
    latex_fragment_str = latex_fragment_str.replace("$^{***}$", "\sym{a}")
    return latex_fragment_str, stargazer


import numpy as np
import statsmodels.api as sm
lowess = sm.nonparametric.lowess

def lowess_ci(x, y, N=100, conf_interval=0.95, lowess_kw=None, num_points=100):
    """
    Perform Lowess regression and determine a confidence interval by bootstrap resampling
    Source: https://www.statsmodels.org/dev/examples/notebooks/generated/lowess.html
    """
    # Automatically generate evaluation points based on the range of x
    eval_x = np.linspace(min(x), max(x), num_points)

    # Lowess smoothing
    smoothed = sm.nonparametric.lowess(exog=x, endog=y, xvals=eval_x, **lowess_kw)

    # Perform bootstrap resamplings of the data and evaluate the smoothing at the fixed set of points
    smoothed_values = np.empty((N, num_points))
    for i in range(N):
        sample = np.random.choice(len(x), len(x), replace=True)
        sampled_x = x[sample]
        sampled_y = y[sample]

        smoothed_values[i] = sm.nonparametric.lowess(
            exog=sampled_x, endog=sampled_y, xvals=eval_x, **lowess_kw
        )

    # Get the confidence interval
    sorted_values = np.sort(smoothed_values, axis=0)
    bound = int(N * (1 - conf_interval) / 2)
    bottom = sorted_values[bound - 1]
    top = sorted_values[-bound]

    return smoothed, eval_x, bottom, top    