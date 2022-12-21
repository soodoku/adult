import matplotlib.pyplot as plt
import numpy as np


def change_width(ax, new_value) :
    # https://stackoverflow.com/a/44542112
    for patch in ax.patches :
        current_width = patch.get_width()
        diff = current_width - new_value

        # we change the bar width
        patch.set_width(new_value)

        # we recenter the bar
        patch.set_x(patch.get_x() + diff * .5)

def fit_exp(x , y, w=None):
    # https://rowannicholls.github.io/python/curve_fitting/exponential.html
#     p = np.polyfit(x, np.log(y), 1, w=np.sqrt(y))    
    p = np.polyfit(x, np.log(y), 1)    
    a = np.exp(p[1])
    b = p[0]
    x_fitted = np.linspace(np.min(x), np.max(x), 100)
    y_fitted = a * np.exp(b * x_fitted)
    return x_fitted, y_fitted

def save_mpl_fig(savepath):
    plt.savefig(f"{savepath}.pdf", dpi=None, bbox_inches="tight", pad_inches=0)
    plt.savefig(f"{savepath}.png", dpi=120, bbox_inches="tight", pad_inches=0)


def annotate_states_on_map(gdf_states):
    ANNOT_SIZE = 21
    for statecode, lat, long in zip(
        gdf_states["STUSPS"], gdf_states["centroid"].x, gdf_states["centroid"].y
    ):
        if statecode == "RI":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 2.5, long),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "DE":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 2.5, long),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "MD":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 2.5, long - 1),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "DC":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 2.5, long - 2),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "FL":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 0.1, long - 0.5),
            )
        elif statecode == "LA":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 1.5, long),
            )
        elif statecode == "CA":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 1.2, long - 0.5),
            )
        elif statecode == "MI":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 0.3, long - 1.1),
            )
        elif statecode == "MN":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 1.3, long - 0.4),
            )
        elif statecode == "VT":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 0.6, long - 0.5),
            )
        elif statecode == "NH":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 1, long + 3),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "ME":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 0.9, long - 0.3),
            )
        elif statecode == "MA":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 6, long + 5),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        elif statecode == "CT":
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat + 3, long - 1),
                arrowprops=dict(arrowstyle="->", lw=0.5),
            )
        else:
            plt.annotate(
                statecode,
                xy=(lat, long),
                fontweight="bold",
                size=ANNOT_SIZE,
                xytext=(lat - 0.9, long - 0.4),
            )
    return None    

import cmasher as cmr
try:
    from mapclassify import Quantiles
except ModuleNotFoundError:
    pass
import matplotlib as mpl

def plot_map(y, gdf):
    k=6
    my_cmap = cmr.lavender_r
    my_cmap = cmr.get_sub_cmap(my_cmap, 0.1, 0.9, N=10)
    
    missing_kwds = {
    "color": "lightgray",
    "hatch": "|-",
    "edgecolor": ".4",
    "label": "NA",
    }
    standard_map_opts = {
        "scheme":"quantiles",
        "k":k,
        "alpha":.8,
        "linewidth":2,
        "edgecolor":".9",
        "missing_kwds":missing_kwds,
    }
    
    fig, ax = plt.subplots(figsize=(16, 10), facecolor="white")
    gdf.plot(y,cmap=my_cmap,**standard_map_opts,ax=ax)
    values = gdf[y].dropna()
    bins = Quantiles(values, k=k).bins 
    bins = [values.min()] + list(bins)  
    norm = mpl.colors.BoundaryNorm(bins, mpl.cm.bone.N)
    cb = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=cmr.lavender_r), 
                      orientation='vertical', 
                      format='%.1f',
                      alpha=0.7, 
                      pad=-0.03,
                      ticks=[values.min(), bins[3], values.max()], # set only 2 ticks, min and max values
                      shrink=.3,
                      aspect=25*0.3,
                      drawedges=True,  # see cb.dividers.set_color('white')
                     )
    cb.ax.tick_params(size=0)
    cb.outline.set_edgecolor(".3")
    cb.outline.set_linewidth(2)
    cb.dividers.set_color('.6')
    cb.dividers.set_linewidth(1.)
    cb.ax.tick_params(labelsize=15)
    cb.set_ticklabels([
        f'<= Low\n     ({bins[0]}%)', 
        f"<= {round(bins[3], 1)}%", 
        f'<= High\n     ({round(bins[-1], 1)}%)',
    ])
    annotate_states_on_map(gdf)
    plt.axis("off")
    plt.tight_layout()
    return None
