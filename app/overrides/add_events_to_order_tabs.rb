Deface::Override.new(:virtual_path => "spree/admin/shared/_order_tabs",
                     :name => "add_events_to_order_tabs",
                     :insert_bottom => "[data-hook='admin_order_tabs']",
                     :text => %q{
                       <li<%== ' class="active"' if current == 'Events' %>>
                         <%= link_to t(:order_events), "/admin/integration/notifications/#{@order.number}" %>
                       </li>
                     },
                     :disabled => false)
