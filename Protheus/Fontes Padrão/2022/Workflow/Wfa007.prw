#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/03/00
#include "WFA007.ch"

function WFA007() // Workflow - Cadastro De/Para
    AXCADASTRO("WF4" , STR0001)
return                            

Function ValCampoHora(cHora)
Local lValida:=.T. 
Local nLenWF4_HR:= 5
	
   If( len(alltrim(M->WF4_HRINI) ) == nLenWF4_HR ).and.( len(alltrim(M->WF4_HRFIM) ) == nLenWF4_HR ) //verifica se os campos de hora estao preenchidos
      If ( (M->WF4_NDIAS) == 1 ) .and. ( ( M->WF4_HRINI ) > ( M->WF4_HRFIM ) ) //verifica se hora ini/fim para 1 dia 
         lValida:=.F.
      EndIf   
   EndIf           
   
Return lValida