ce programme  est correct


 L'arbre de syntaxe astraite: 
Mp Se Af X1 15 IfThEl X1  Af X2 20 Af X3 30 

Le code C3A: 
ET1       :Afc   :15        :          :CT2       
ET0       :Af    :X1        :CT2       :
ET3       :Sk    :          :          :X1        
ET11      :Jz    :X1        :          :ET8       
ET5       :Afc   :20        :          :CT6       
ET4       :Af    :X2        :CT6       :
ET12      :Jp    :          :          :ET10      
ET8       :Afc   :30        :          :CT9       
ET7       :Af    :X3        :CT9       :
ET10      :Sk    :          :          :
ET13      :St    :          :          :


Le code Y86: 
                  .pos      0         #debut zone code 
INIT      :irmovl Data,     %edx      #adresse de la zone de donnees
           irmovl 256,      %eax      #espace pile
           addl   %edx,     %eax                
           rrmovl %eax,     %esp      #init pile 
           rrmovl %eax,     %ebp                
ET1       :irmovl 15,       %eax      #trad Afc    15                  CT2       
           rmmovl %eax,     12(%edx)            
ET0       :mrmovl 12(%edx), %eax      #trad Af     X1        CT2        
           rmmovl %eax,     24(%edx)            
ET3       :nop                        #trad Sk                         X1        
ET11      :mrmovl 24(%edx), %eax      #trad Jz     X1                  ET8       
           andl   %eax,     %eax                
           je     ET8                           
ET5       :irmovl 20,       %eax      #trad Afc    20                  CT6       
           rmmovl %eax,     8(%edx)             
ET4       :mrmovl 8(%edx),  %eax      #trad Af     X2        CT6        
           rmmovl %eax,     20(%edx)            
ET12      :jmp    ET10                #trad Jp                         ET10      
ET8       :irmovl 30,       %eax      #trad Afc    30                  CT9       
           rmmovl %eax,     4(%edx)             
ET7       :mrmovl 4(%edx),  %eax      #trad Af     X3        CT9        
           rmmovl %eax,     16(%edx)            
ET10      :nop                        #trad Sk                          
ET13      :halt                       #trad St                          
MUL       :nop                        #ssprog mult:M[M[%edx]]:=X*Y
           mrmovl 4(%esp),  %eax      #A := X   
           mrmovl 8(%esp),  %ebx      # B:= Y   
           andl   %eax,     %eax      # si A==0 return 0
           je     END                           
SIGN      :nop                        #si A <= 0 alors (X:= -A,Y:= -B)
           jg     MULPLUS             #cas ou A > 0
           irmovl 0,        %ecx                
           subl   %eax,     %ecx                
           rrmovl %ecx,     %eax                
           rmmovl %eax,     4(%esp)   #X := -A  
           irmovl 0,        %ecx                
           subl   %ebx,     %ecx                
           rrmovl %ecx,     %ebx                
           rmmovl %ebx,     8(%esp)   #Y := -B  
MULPLUS   :nop                        #ssprog X>0->M[M[%edx]]:=X*Y
           mrmovl 4(%esp),  %eax      #A := X   
           andl   %eax,     %eax      # si X==0 return 0
           je     END                           
           irmovl 1,        %esi      # A:=A-1  
           subl   %esi,     %eax                
           mrmovl 8(%esp),  %ebx      # B:= Y   
           pushl  %ebx                # empiler B, puis A
           pushl  %eax                          
           call   MULPLUS             # M[%edx]:= A * B=(X-1) * Y
           popl   %eax                # depiler A puis B
           popl   %eax                          
           mrmovl 0(%edx),  %eax      # M[%edx]:= M[%edx] + Y
           mrmovl 8(%esp),  %ebx                
           addl   %ebx,     %eax                
           rmmovl %eax,     0(%edx)   #end MUL(X<>0) ret(Z)
           ret                                  
END       :irmovl 0,        %eax      #end MUL(X==0) ret(Z)
           rmmovl %eax,     0(%edx)             
           ret                                  
                  .align    8         #debut zone donnees
Data      :                                     
