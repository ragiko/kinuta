# coding: utf-8

require "pp"

class MyBlock
    attr_accessor :mem_increment, :block

    def initialize(obj_str)
        @obj_str = obj_str
        @Ele = Struct.new(:s, :e, :label)
        @block = block # TODO: elementsにするとわかりやすい
        @mem_increment = nil
    end

    def block
        a = []
        @obj_str.split("\n").each do |l|
            match = l.match(/(\d*?) (\d*?) (.*?) /) 
            if !match.nil? 
                s = match[1].to_i
                e = match[2].to_i
                label = match[3]

                a << @Ele.new(s, e, label)
            end
        end
        a
    end

    def block_last_end_frame
        @block[block.size-1].e
    end

    def update_ele_with_incremenet!
        @block.each do |ele| 
            ele.s += @mem_increment
            ele.e += @mem_increment
        end
        _refactor_ele
    end

    # 行数が合うようにちゃんと調節
    def _refactor_ele
        @block.each do |ele| 
            ele.s += 100000
        end
    end
end

class MyFileHelper
    def initialize(file_path)
        @lines = File.readlines(file_path) 
    end

    def add_label_to_lines(l_num1, l_num2, label)
        # r = []
        # @lines.each_with_index do |l, i|
        #     if (l_num1 <= i+1  && i+1 <= l_num2 )
        #         r << label + "," + l
        #     else 
        #         r << l
        #     end
        # end
        # @lines = r
        t = @lines[l_num1..l_num2]

        p l_num1
        t.each do |line|
            line = label + "," + line
        end
        @lines[l_num1..l_num2] = t
    end

    def out_file(file_path)
        File.write(file_path, @lines.join(""))    
    end
end

obj_str = File.read("train_label.mlf")
objs_str = obj_str.split(/^.$/)
objs_str.delete("\n") # 最後の余分を削除

blocks = objs_str.map {|obj_str| MyBlock.new(obj_str) }

# blockのフレームをインクリメントするものを記憶
sum = 0
blocks.each do |block|
    end_frame = block.block_last_end_frame
    block.mem_increment = sum
    sum += end_frame.to_i
end

# エレメントの行数をアップデート
blocks.map {|block| block.update_ele_with_incremenet! }
pp blocks

#///////////////////////////
exit
#///////////////////////////

# ラベルの書き込み
mf = MyFileHelper.new("test.csv")

blocks.each_with_index do |block, i|
    puts i.to_s 
    block.block.each do |ele|
        s = ele.s/100000
        e = ele.e/100000
        label = ele.label
        mf.add_label_to_lines(s, e, label)
    end
end

mf.out_file("test2.label")
