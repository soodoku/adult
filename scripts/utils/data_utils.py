import pandas as pd
import statsmodels.api as sm
import statsmodels.formula.api as smf


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
