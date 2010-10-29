/*
 * Copyright (C) 2010 Michal Hruby <michal.mhr@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA.
 *
 * Authored by Michal Hruby <michal.mhr@gmail.com>
 *
 */

namespace Sezen
{
  namespace Utils
  {
    private static Gdk.Pixmap transparent_pixmap = null;
    
    public static void make_transparent_bg (Gtk.Widget widget)
    {
      unowned Gdk.Window window = widget.get_window ();
      if (window == null) return;
      
      if (widget.is_composited ())
      {
        if (transparent_pixmap == null)
        {
          transparent_pixmap = new Gdk.Pixmap (window, 1, 1, -1);
          var cr = Gdk.cairo_create (transparent_pixmap);
          cr.set_operator (Cairo.Operator.CLEAR);
          cr.paint ();
        }
        window.set_back_pixmap (transparent_pixmap, false);
      }
    }
    
    private static void on_style_set (Gtk.Widget widget, Gtk.Style? prev_style)
    {
      if (widget.get_realized ()) make_transparent_bg (widget);
    }
    
    private static void on_composited_change (Gtk.Widget widget)
    {
      if (widget.is_composited ()) make_transparent_bg (widget);
      else widget.modify_bg (Gtk.StateType.NORMAL, null);
    }
    
    public static void ensure_transparent_bg (Gtk.Widget widget)
    {
      if (widget.get_realized ()) make_transparent_bg (widget);
      
      widget.realize.disconnect (make_transparent_bg);
      widget.style_set.disconnect (on_style_set);
      widget.composited_changed.disconnect (on_composited_change);
      
      widget.realize.connect (make_transparent_bg);
      widget.style_set.connect (on_style_set);
      widget.composited_changed.connect (on_composited_change);
    }
  }
}

