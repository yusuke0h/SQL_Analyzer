class KaigyoController < ApplicationController
  def index
    if params[:data]
      @sql = params[:data][:sql]
      @analyzed_sal = sql_analyze @sql
      @sql_change = {
        fields: "SELECT",
        tables: "FROM",
        terms: "WHERE",
        etc: "Other",
      }
      @tables = Hash.new(0)
      @analyzed_sal[:tables].each do |from_sentence|
        from_terms = from_sentence.split.map { |e| e.strip }
        from_terms.each_with_index do |term, index|
          case from_terms[index-1]
          when /FROM/
            @tables[term] += 1
          when /JOIN/
            @tables[term] += 1
          end
        end
      end
    end
  end

  private
  def sql_analyze sql
    sql_funcs = ["SELECT", "FROM", "WHERE", "ORDER BY", "GROUP BY", "LIMIT"]
    replaced_sql = sql
    sql_funcs.each do |sql_func|
      replaced_sql = replaced_sql.gsub(sql_func, "*****#{sql_func}")
    end

    etc = []
    select, from, where = ["", "", ""]
    sentences = replaced_sql.split("*****").reject{ |e| e.strip == "" }.map { |e| e.strip }
    sentences.each do |sentence|
      case sentence
      when /SELECT/
        select << sentence
        select << ','
      when /FROM/
        from << sentence
        from << ','
      when /WHERE/
        where << sentence
        where << '******'
      else
        etc << sentence
      end
    end

    fields = select.split(",").map { |e| e.strip }
    tables = from.split(",").map { |e| e.strip }
    tmp_terms = where.gsub("AND", "******AND").gsub("OR", "******OR").split("******")
    terms = []
    next_flg = false
    tmp_terms.each_with_index do |term, index|
      if term.include?("between")
        terms << [term.strip, tmp_terms[index + 1].strip].join(" ")
        next_flg = true
      else
        if next_flg
          next_flg = false
          next
        end
        terms << term.strip
      end
    end
    return {fields: fields, tables: tables, terms: terms, etc: etc}
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

    output_text << "\n"
    output_text << '===Others==='
    output_text << "\n"
    analyzed_sal[:etc].each{|e|
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