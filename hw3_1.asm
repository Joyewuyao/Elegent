DATA SEGMENT
    line  db 13,10,'$'                                    ;换行
    mess  db 'WHAT IS THE DATE(MM-DD-YYYY)?',13,10,'$'    ;开始显示
    year  db 13,10,'THE YEAR :$'                          ;输出年份显示
    month db 13,10,'THE MONTH:$'                          ;输出月份显示
    day   db 13,10,'THE DAY  :$'                          ;输出日值显示
    close db 13,10,'Accomplish!$'                         ;结束输出显示
    time  db 20 dup(?)                                    ;存放日期
       
DATA ENDS

CODE SEGMENT
           assume cs:code,ds:data
    start: 
           mov    AX,DATA
           mov    DS,AX

           mov    dx,offset mess     ;显示提示信息"WHAT IS THE DATE(MM/DD/YY)?"
           mov    ah,9
           int    21h

           mov    cx,10              ;共需输入十个字符
           mov    si,0
           call   GetNum             ;调用Getnum，接收年、月、日值

           mov    dx,offset year     ;输出提示“THE YEAR :”
           mov    ah,9
           int    21h

           mov    si,6
           call   Disp               ;调用Disp，输出年份

           mov    dx,offset month    ;输出提示“THE MONTH:”
           mov    ah,9
           int    21h

           mov    si,0
           call   Dispp              ;调用Dispp,输出月份

           mov    dx,offset day      ;输出提示“THE DAY  :”
           mov    ah,9
           int    21h

           mov    si,3
           call   Dispp              ;调用Dispp,输出日值

           mov    dx,offset close
           mov    ah,9
           int    21h
          
           mov    ah,4ch             ;退出程序
           int    21h

    GetNum:mov    ah,1               ;1号功能，键盘输入，键入的值在al
           int    21h
           mov    time[si],al        ;将输入字符存入time中
           inc    si
           loop   GetNum             ;循环输入，共四个字符
           ret
    ;年份有四位数，循环四次
    Disp:  mov    dl,time[si]
           mov    ah,2
           int    21h
           inc    si
           mov    dl,time[si]
           mov    ah,2
           int    21h
           inc    si
           mov    dl,time[si]
           mov    ah,2
           int    21h
           inc    si
           mov    dl,time[si]
           mov    ah,2
           int    21h
           ret
    ;月份和日有两位数，循环两次
    Dispp: mov    dl,time[si]
           mov    ah,2
           int    21h
           inc    si
           mov    dl,time[si]
           mov    ah,2
           int    21h
           ret
CODE ENDS
    END START