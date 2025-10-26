module ApplicationHelper

    def sortable(column, title = nil)
      title ||= column.titleize
      direction = (column == params[:sort] && params[:direction] == "asc") ? "desc" : "asc"
      link_to title, { sort: column, direction: direction }, class: "text-decoration-none"
    
        icon =
          if column == params[:sort]
            params[:direction] == "asc" ? "▲" : "▼"
          else
            "↕"
          end
    
        link_to "#{title} #{icon}".html_safe,
                { sort: column, direction: direction },
                class: "text-white text-decoration-none fw-bold"
      end

end
