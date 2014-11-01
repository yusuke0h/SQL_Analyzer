class KaigyoController < ApplicationController
  def index
    if params[:data]
      sql = params[:data][:sql]
      analyzed_sal = sql_analyze sql
      @processed_text = sql_textnize(sql, analyzed_sal).gsub("\n", "<br>")
    end
  end

  private
  def sql_analyze sql
    select, from, where = sql.split(/SELECT|FROM|WHERE/).reject{ |e| e == "" }.map { |e| e.strip }

    fields = select.split(",").map { |e| e.strip }
    tables = from.split(",").map { |e| e.strip }
    tmp_terms = where.split(/AND|OR/)
    terms = []
    next_flg = false
    tmp_terms.each_with_index do |term, index|
      if term.include?("between")
        terms << [term.strip, tmp_terms[index + 1].strip].join(" AND ")
        next_flg = true
      else
        if next_flg
          next_flg = false
          next
        end
        terms << term.strip
      end
    end
    return {fields: fields, tables: tables, terms: terms}
  end

  def sql_textnize sql, analyzed_sal
    output_text = ""

    output_text << '===RAW SQL==='
    output_text << "\n"
    output_text << sql
    output_text << "\n"

    output_text << "\n"
    output_text << '===SELECT fields==='
    output_text << "\n"
    analyzed_sal[:fields].each{|e|
      output_text << e
      output_text << "\n"
    }


    output_text << "\n"
    output_text << '===FROM tables==='
    output_text << "\n"
    analyzed_sal[:tables].each{|e|
      output_text << e
      output_text << "\n"
    }


    output_text << "\n"
    output_text << '===WHERE terms==='
    output_text << "\n"
    analyzed_sal[:terms].each{|e|
      output_text << e
      output_text << "\n"
    }

    return output_text
  end

end



      # text.split(/^$/).each do |line|
      #   line = line.gsub("\n", "")
      #   if line.size / num > 0
      #     0.upto(line.size / num) do |term|
      #       lines << line[num*term..num*(term+1)-1].strip
      #     end
      #   else
      #     lines << line.strip
      #   end
      # end

      # 0.upto(text.size / num) do |term|
      #   lines << text[num*term..num*(term+1)-1].strip
      # end