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