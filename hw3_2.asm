data segment
       ;以下是表示21年的21个字符串
            db '1975','1976','1977','1978','1979','1980','1981','1982','1983'
            db '1984','1985','1986','1987','1988','1989','1990','1991','1992'
            db '1993','1994','1995'
        
       ;以下是表示21年公司总收的21个dword型数据
            dd 16,22,382,1356,2390,8000,16000,24486,50065,97479,140417,197514
            dd 345980,590827,803530,1183000,1843000,2759000,3753000,4649000,5937000
        
       ;以下是表示21年公司雇员人数的21个word型数据
            dw 3,7,9,13,28,38,130,220,476,778,1001,1442,2258,2793,4037,5635,8226
            dw 11542,14430,45257,17800

       mem  db 7 dup(?)                          ;作为中间存储单元存放收入、雇员人数以及平均收入

data ends

table segment
             db 21 dup('year summ ne ?? ')       ;共21个组数据
table ends

code segment
              assume ds:data, es:table, cs:code
       start: 

       ;初始化2个数据段，将ds指向data，es指向table
              mov    ax,data
              mov    ds,ax
              mov    ax,table
              mov    es,ax

       ;初始化偏址寄存器变量
              mov    bx,0
              mov    si,0
              mov    di,0

       ;共21行，循环21次
              mov    cx,21

       ;s循环将年份、收入、雇员数以及平均收入等写入table段中
       s:     

       ;写入年份
              mov    ax,[bx]
              mov    es:[si],ax
              mov    ax,[bx+2]
              mov    es:[si+2],ax

       ;写入空格
              mov    al,20H
              mov    es:[si+4],al                     ;table中年份4字节，所以空格在4

       ;写入收入
              mov    ax,[bx+84]                       ;一个年份4字节，共21所以需84字节，所以收入存储从84开始
              mov    es:[si+5],ax
              mov    ax,[bx+86]
              mov    es:[si+7],ax

       ;写入空格
              mov    al,20H
              mov    es:[si+9],al

       ;雇员数
              mov    ax,[di+168]                      ;收入也是占用4字节，共84字节，84+84=168，所以从168开始是雇员数
              mov    es:[si+10],ax

       ;写入空格
              mov    al,20H
              mov    es:[si+12],al

       ;人均收入，高16位送入dx，低16位送入ax
              mov    ax,[bx+84]
              mov    dx,[bx+86]

       ;用个bp变量存储除数
              mov    bp,[di+168]
              div    bp                               ;16位除法指令，商存储在ax中，余数存储在dx中
              mov    es:[si+13],ax                    ;将商的结果ax写入table段中

       ;写入空格
              mov    al,20H
              mov    es:[si+15],al

       ;bx、si、di变量的递增
              add    bx,4                             ;年份和总收入都是双字单元，故bx的递增量是4
              add    si,16                            ;table中每行是16个字节，偏移量为16
              add    di,2                             ;人数是字单元，故di的递增量是2
              dec    cx                               ;循环一次，cx减1
              je     here
              jmp    s

       here:  
              mov    si,0                             ;初始化偏移量si为0
              mov    cx,21                            ;共21组数据，循环21次

       ;s1循环进行每组数据输出，循环21次输出
       s1:    push   cx                               ;将cx压入栈保护数据
              call   year                             ;调用year，输出年份

              mov    di,6                             ;最大数据为7位数，0-6共7个数存储
              mov    ax,es:[si+5]                     ;将低16位存储在ax中
              mov    dx,es:[si+7]                     ;高16位存储在dx中

       ;由于最大数据过大，以高16位中是否大于10，即10*2^16=655360为分界点，使用不同方法输出
              cmp    dx,10
              jb     s2

       ;若dx里大于10，则将该数据除以100，分开输出商以及余数，即为该数
              mov    bx,100
              div    bx

              mov    bp,dx                            ;用bp暂时存放除以100后的余数，即数字后两位

       ;调用store和output子程序输出除以100后的商
              mov    dx,0
              mov    di,6
              call   store                            ;调用store子程序来存储除了最后两位的数字
              mov    cx,10
              add    cx,di                            ;通过di可知输出的数据，以此来确认后续空格的次数
              call   output                           ;调用output输出存储在num中的数据

       ;余数为两位数，将其除以10，分别输出商和余数即可
              mov    ax,bp                            ;将余数赋值给ax
              mov    bx,10                            ;用bx存储除数10
              mov    dx,0                             ;dx为0
              div    bx                               ;除以10，商在ax中，余数在dx中
              mov    bp,dx                            ;将余数暂时存储在bp中后续输出
              mov    dx,ax                            ;输出存储在ax中的商
              add    dx,0030h
              mov    ah,2
              int    21h
              mov    dx,bp                            ;输出余数
              add    dx,0030h
              mov    ah,2
              int    21h

              call   blank                            ;调用blank子程序输出空格，次数由上述cx决定
              jmp    s3                               ;输出总收入成功，跳转至s3输出后续雇员数以及平均收入

       ;若dx小于10，说明数据没超过最大值，则可直接调用store和output子程序输出总收入
       s2:    call   store
              mov    cx,12
              add    cx,di                            ;cx控制后续空格输出次数
              call   output
              call   blank                            ;调用blank子程序输出空格，次数由上述cx决定

       ;调用store和output子程序输出雇员数
       s3:    mov    di,6
              mov    ax,es:[si+10]
              mov    dx,0
              call   store
              mov    cx,12
              add    cx,di                            ;cx控制后续空格输出次数
              call   output
              call   blank                            ;调用blank子程序输出空格，次数由上述cx决定

       ;调用store和output子程序输出平均收入
              mov    di,6
              mov    ax,es:[si+13]
              mov    dx,0
              call   store
              mov    cx,12
              add    cx,di                            ;cx控制后续空格输出次数
              call   output
               
       ;输出换行符
              mov    dl,10
              mov    ah,2
              int    21h

              add    si,16                            ;每组数据占用16字节，所以每次循环si加16
              pop    cx                               ;将cx还原
              dec    cx                               ;循环一次，cx减1
              je     there                            ;跳转至there
              jmp    s1
       there: 
              mov    ax,4c00h                         ;结束程序
              int    21h

       ;year子程序，用于输出年份
       year:  mov    dl,es:[si]
              mov    ah,2
              int    21h
              mov    dl,es:[si+1]
              mov    ah,2
              int    21h
              mov    dl,es:[si+2]
              mov    ah,2
              int    21h
              mov    dl,es:[si+3]
              mov    ah,2
              int    21h
              mov    dl,9
              mov    ah,2
              int    21h                              ;输出一个tab键
              mov    dl,9
              mov    ah,2
              int    21h                              ;输出一个tab键
              ret

       ;store子程序，将数据中的每位数存储在num中
       store: 
              mov    bx,10                            ;把各个位转换为数值，如ax中的81，转换为 8,1存在内存中
              div    bx                               ;ax除以10，得到商在ax中，余数在dx中
              mov    [mem+di],dl                      ;将得到的数存储到[result]中
              mov    dx,0
              dec    di
              cmp    ax,0                             ;商是否为0，为0算法结束
              ja     store
              ret

       ;output子程序，输出存储在num中的数据
       output:inc    di
              mov    dh,0
              mov    dl,[mem+di]
              add    dl,30h                           ;转为ascii
              mov    ah,2
              int    21h                              ;输出
              cmp    di,6
              jb     output
              ret

       ;blank子程序，输出空格，空格个数由cx决定
       blank: mov    dl,32
              mov    ah,2
              int    21h
              loop   blank
              ret
       

code ends
end start