#-- copyright
# OpenProject My Project Page Plugin
#
# Copyright (C) 2011-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.md for more details.
#++

module MyProjectsOverviewsHelper
  include WorkPackagesFilterHelper

  TOP = %w(top)
  MIDDLE = %w(left right)
  HIDDEN = %w(hidden)

  def field_list
    TOP + MIDDLE + HIDDEN
  end

  def visible_fields
    TOP + MIDDLE
  end

  def method_missing(name)
    constant_name = name.to_s.gsub('_fields', '').upcase
    if MyProjectsOverviewsHelper.const_defined? constant_name
      return MyProjectsOverviewsHelper.const_get constant_name
    end
    raise NoMethodError
  end

  def grid_field(name)
    css_classes = %w(block-receiver list-position) + [name]
    data = {
      :'ajax-url' => ajax_url(name),
      position: name
    }
    content_tag :div, id: "list-#{name}", class: css_classes, data: data do
      ActiveSupport::SafeBuffer.new(blocks[name].map { |b| construct b }.join)
    end
  end

  protected

  def block_available?(block)
    controller.class.available_blocks.keys.include? block
  end

  def construct(block)
    if block_available? block
      render partial: 'block', locals: { block_name: block }
    elsif block.respond_to? :to_ary
      render partial: 'block_textilizable', locals: { block_name: block }
    end
  end

  def ajax_url(name)
    url_for controller: '/my_projects_overviews',
            action: 'order_blocks',
            group: name
  end
end
