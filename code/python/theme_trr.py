from colorsys import hls_to_rgb, rgb_to_hls

from plotnine import (element_blank, element_line, element_text,
                      scale_color_gradient, scale_color_manual,
                      scale_fill_gradient, scale_fill_manual, theme,
                      theme_gray)


def theme_trr(plot_type="default", legend=False, text_size=11, axis_y_horizontal=True):

    plot_type = plot_type.lower()
    valid_plots = ["bar", "box", "lollipop", "line",
                   "scatter", "smoother", "default"]
    if not plot_type in valid_plots:
        raise ValueError(
            "theme_trr: plot_type has to be 'default', 'bar', 'box', 'lollipop','line', 'scatter' or 'smoother'."
        )

    return (
        theme_gray(base_family="sans") +
        theme(
            text=element_text(size=text_size),
            axis_title_y=element_text(
                angle=0) if axis_y_horizontal else element_text(angle=90),
            axis_ticks=element_blank(),
            axis_line=element_blank() if plot_type in [
                "line", "scatter", "default"] else element_line(size=0.3, lineend="round"),
            legend_position="top" if legend else "none",
            legend_background=element_blank(),
            legend_margin=1,
            legend_key=element_blank(),
            legend_direction="horizontal",
            legend_box_background=element_blank(),
            panel_background=element_blank(),
            panel_grid=element_line(color="#EBEBEBFF", size=0.4),
            panel_grid_minor_x=element_blank() if plot_type in [
                "bar", "box", "line", "smoother", "default"] else None,
            panel_grid_major_x=element_blank() if plot_type in [
                "bar", "box", "line", "scatter", "default"] else None,
            panel_grid_minor_y=element_blank() if plot_type in [
                "lollipop", "scatter", "smoother"] else None,
            panel_grid_major_y=element_blank() if plot_type == "lollipop" else None,
            plot_background=element_blank(),
            plot_title=element_text(weight="bold")
        )
    )


col_trr266_petrol = "#1B8A8F"
col_trr266_yellow = "#FFB43B"
col_trr266_blue = "#6ECAE2"
col_trr266_red = "#944664"
col_trr266_nightblue = "#22355D"
col_trr266_iceblue = "#1D758D"
col_trr266_darkgreen = "#224B4F"

trr266_colors = [
    col_trr266_petrol, col_trr266_yellow, col_trr266_blue, col_trr266_red, col_trr266_nightblue, col_trr266_iceblue, col_trr266_darkgreen
]


def scale_fill_trr266_d(**kwargs):
    return scale_fill_manual([col+'FF' for col in trr266_colors], **kwargs)


def scale_fill_trr266_c(base_color: str = col_trr266_petrol, **kwargs):
    return scale_fill_gradient(lighten(base_color, 0.9), base_color, **kwargs)


def scale_color_trr266_d(**kwargs):
    return scale_color_manual([col+'FF' for col in trr266_colors], **kwargs)


def scale_color_trr266_c(base_color: str = col_trr266_petrol, **kwargs):
    return scale_color_gradient(lighten(base_color, 0.9), base_color, **kwargs)


def lighten(color: str, factor: float):
    '''
    Takes a hex color code and lightens it by a given factor.
    '''
    color = color.lstrip('#')
    r, g, b = tuple(int(color[i:i+2], 16) for i in (0, 2, 4))
    h, l, s = rgb_to_hls(r / 255.0, g / 255.0, b / 255.0)
    l = max(min(l * (1 + factor), 1.0), 0.0)
    r, g, b = hls_to_rgb(h, l, s)
    r, g, b = int(r * 255), int(g * 255), int(b * 255)
    return "#%02x%02x%02x" % (r, g, b)
