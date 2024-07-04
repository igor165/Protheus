#Include 'Protheus.ch'
#Include 'FWBrowse.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOPCONN.CH"

#DEFINE EDITAL			1
#DEFINE PROCESSO		2
#DEFINE REGRA			3
#DEFINE MODALIDADE		4
#DEFINE DESCREGRA		5
#DEFINE TIPO			6

Function GCPAtuVer()

PRIVATE aList		:= Processa( {|| EdtAberto() }, "Aguarde...", "Carregando os Editais em Aberto",.F.) //EdtAberto()
PRIVATE aModalid	:= Processa( {|| ModalExist() }, "Aguarde...", "Carregando as modalidades existentes",.F.) //ModalExist()

Processa( {|| ExecRot1() }, "Aguarde...", "Atualizando as tabelas de Editais",.F.)
Processa( {|| MontaBRW() }, "Aguarde...", "Carregando os Editais em Aberto",.F.) //ModalExist()
Processa( {|| AtuCPs() }, "Aguarde...", "Atualizando CP3, CP6 e Modalidade",.F.) //ModalExist()
 

MSGALERT( "Processamento", "Processamento finalizado!" )

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} 
AtuaModali()
Função que atualiza os tipos e modalidades - compatibilização do GCP antigo com o novo

@author Taniel Balsanelli
@since 08/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function AtuaModali()
Local cQuery	:= ""      
Local nX		:= 0
Local cRegra	:= ""
Local cModali	:= ""
Local cTipo		:= ""
		                   
DEFAULT aModalid	:= {}


For nX := 1 To Len(aModalid)

    cRegra	:= aModalid[nX,REGRA]
	cModali := aModalid[nX,MODALIDADE]
	cTipo	:= aModalid[nX,TIPO]
	
	dbSelectArea("COZ")
	COZ->(DbSetOrder(1)) //COZ_FILIAL+COZ_REGRA+COZ_MODALI+COZ_TIPO
	COZ->(DbGoTop())

	If (COZ->(DbSeek(xFilial("COZ")+cRegra+cModali+cTipo))) 
        nRecno := COZ->(Recno())                  			
		Do Case			
		Case COZ_MODALI = "CV" .And. COZ_TIPO $ "MP|MT|TP" //Update 1     			
	        
	        //Deleta todos os registros                    
			While COZ->(!Eof()) .And. COZ_FILIAL+COZ_REGRA+COZ_MODALI+COZ_TIPO == xFilial("COZ")+cRegra+cModali+cTipo
	
	  			If COZ_MODALI = "CV" .And. COZ_TIPO $ "MP|MT|TP"
					RecLock("COZ",.F.)
					COZ->(dbDelete())				
					COZ->(MsUnlock()) 	  			
	  			EndIf
	  		
	  			COZ->(dbSkip())
			EndDo

			//Inclui um unico registro
			COZ->(DbGoTop())
			If !(COZ->(DbSeek(xFilial("COZ")+cRegra+"CV"+"VZ"))) 
				If !Empty(cModali)
					RecLock("COZ",.T.)  
					COZ->COZ_FILIAL	:= xFilial("COZ")
					COZ->COZ_REGRA	:= cRegra 
					COZ->COZ_MODALI	:= "CV" //cModali
					COZ->COZ_TIPO	:= "VZ"  
					COZ->COZ_USADO	:= .T.
					COZ->COZ_DESCRI	:= "Vazio"
					COZ->(MsUnlock())
				EndIf
			EndIf
			
		Case COZ_MODALI == "TP" .And. COZ_TIPO == "MP" //Update 2     			
					
			While COZ->(!Eof()) .And. COZ_FILIAL+COZ_REGRA+COZ_MODALI+COZ_TIPO == xFilial("COZ")+cRegra+cModali+cTipo
	
	  			If COZ_MODALI = "TP" .And. COZ_TIPO == "MP"
					RecLock("COZ",.F.)
					COZ->(dbDelete())
					COZ->(MsUnlock())
	  			EndIf
	  		
	  			COZ->(dbSkip())
			EndDo
	  		
			//Inclui um unico registro 
			COZ->(DbGoTop())
			If !(COZ->(DbSeek(xFilial("COZ")+cRegra+"TP"+"TP")))
				If !Empty(cModali)
					RecLock("COZ",.T.)  
					COZ->COZ_FILIAL	:= xFilial("COZ")
					COZ->COZ_REGRA	:= cRegra 
					COZ->COZ_MODALI	:= "TP" //cModali
					COZ->COZ_TIPO	:= "TP"  
					COZ->COZ_USADO	:= .T.
					COZ->COZ_DESCRI	:= "Técnica e Preço"
					COZ->(MsUnlock())
				EndIf
			EndIf
							
		Case COZ_MODALI == "PG" .And. COZ_TIPO $ "MP|PP" //Update 3 e 4
						
			While COZ->(!Eof()) .And. COZ_FILIAL+COZ_REGRA+COZ_MODALI+COZ_TIPO == xFilial("COZ")+cRegra+cModali+cTipo
	
	  			If COZ_MODALI = "PG" .And. COZ_TIPO $ "MP|PP"
					RecLock("COZ",.F.)
					COZ->(dbDelete())
					COZ->(MsUnlock())
	  			EndIf
	  		
	  			COZ->(dbSkip())
			EndDo
	  		
			//Inclui um unico registro
			COZ->(DbGoTop())
			If !(COZ->(DbSeek(xFilial("COZ")+cRegra+"PG"+"PR"))) .And. !Empty(cModali)
				If !Empty(cModali)
					RecLock("COZ",.T.)  
					COZ->COZ_FILIAL	:= xFilial("COZ")
					COZ->COZ_REGRA	:= cRegra 
					COZ->COZ_MODALI	:= "PG" //cModali
					COZ->COZ_TIPO	:= "PR"  
					COZ->COZ_USADO	:= .T.
					COZ->COZ_DESCRI	:= "Menor Preço"
					COZ->(MsUnlock())
				EndIf
			EndIf
								
		EndCase					  										   
		
	EndIf
	
Next nX


Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuaStatus()
Função que atualiza os status - compatibilização do GCP antigo com o novo

@author Taniel Balsanelli
@since 09/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function  AtuaStatus()
Local cQuery := ""

//Update 1 - Edital em aberto
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_STATUS = '1' "
cQuery += " WHERE "
cQuery += " CO1_ETAPA <> 'PC' "
cQuery += " OR CO1_ETAPA <> 'CO' "
cQuery += " OR CO1_ETAPA <> 'PF' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Edital em aberto" + TCSQLError())
EndIf

//Update 2 - Edital encerrado
cQuery := ""
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_STATUS = '2' "
cQuery += " WHERE "
cQuery += " CO1_ETAPA = 'PC' "
cQuery += " OR CO1_ETAPA = 'CO' "
cQuery += " OR CO1_ETAPA = 'PF' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Edital em aberto" + TCSQLError())
EndIf

//Update 3 - Edital remanescente
cQuery := ""
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_STATUS = '3' "
cQuery += " WHERE "
cQuery += " CO1_REMAN = 'T' "
TCSQLExec(cQuery) 
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 3 - Edital em aberto" + TCSQLError())
EndIf

//Update 4 - Eidtal fracassado
cQuery := ""
cQuery := "UPDATE" 
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'FI', " 
cQuery += " CO1_STATUS = '5' " 
cQuery += " WHERE "
cQuery += " CO1_ETAPA = 'PR' "
TCSQLExec(cQuery)
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 4 - Edital em aberto" + TCSQLError())
EndIf

//Update 5 - Edital Impugnado
cQuery := ""
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_STATUS = '4' "
cQuery += " WHERE "
cQuery += " CO1_ETAPA = 'IM' " 
cQuery += " OR CO1_ETAPA = 'SR' "
TCSQLExec(cQuery)
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 5 - Edital em aberto" + TCSQLError())
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuaCOPC()
Função que atualiza o CO1_GERDOC e CO1_COPC

@author Taniel Balsanelli
@since 09/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function AtuaCOPC()
Local cQuery := ""

//Update 1 - Quando é PC ou Contrato, atualiza os campos para documento P/ Compra/Contrato
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_COPC = '1', "
cQuery += " CO1_GERDOC = '1', " 
cQuery += " CO1_IMEDIA = '2' "
cQuery += " WHERE "
cQuery += " CO1_COPC IN ('1','2','P') "
TCSQLExec(cQuery)   

If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Atualiza documento p/ compra " + TCSQLError())
EndIf


//Update 2 - Quando é pedido de venda, atualiza os campos para documento p/ Venda
cQuery := "" 
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_COPC = '2', "
cQuery += " CO1_GERDOC = '2', "
cQuery += " CO1_IMEDIA = '2' "
cQuery += " WHERE "
cQuery += " CO1_COPC = '3' "
TCSQLExec(cQuery)
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Atualiza documento p/ Venda " + TCSQLError())
EndIf
     

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuFORMLC()
Função que atualiza o CO1_FORMLC de acordo com o tipo de 
Pregão (Eletrônico ou Presencial)

@author Flavio Lopes Rasta
@since 06/02/2014
@version P12
/*/
//-------------------------------------------------------------------
Function AtuFORMLC()
Local cQuery := ""

//Update 1
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_FORMLC = '1', "
cQuery += " CO1_TIPO = 'PR' " 
cQuery += " WHERE "
cQuery += " CO1_MODALI = 'PG' "
cQuery += " AND CO1_TIPO IN ('PE','MP') " 
TCSQLExec(cQuery)   

If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Atualiza o CO1_FORMLC de acordo com o tipo de Pregão " + TCSQLError())
EndIf

//Update 2
cQuery := ""
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_FORMLC = '2', "
cQuery += " CO1_TIPO = 'PR' " 
cQuery += " WHERE "
cQuery += " CO1_MODALI = 'PG' "
cQuery += " AND CO1_TIPO = 'PP' " 
TCSQLExec(cQuery)
     
If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Atualiza o CO1_FORMLC de acordo com o tipo de Pregão " + TCSQLError())
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuaCmbBox()
Função que atualiza ComboBox

@author Taniel Balsanelli
@since 09/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function AtuaCmbBox()
Local cQuery := ""

cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ENV = '2', "
cQuery += " CO1_COM = '2', "
cQuery += " CO1_TEC = '2' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Atualiza ComboBox " + TCSQLError())
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopularCO7()
Função que popula alguns campos da CO7. Tratamento das etapas.

@author Taniel Balsanelli
@since 10/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopularCO7()
Local cUser	    := Alltrim(RetCodUsr())
Local cTime 		:= Time()
Local cAliasSql 	:= ""

cAliasSql	:= GetNextAlias()
 
BeginSQL Alias cAliasSql
	SELECT 
		CO1.CO1_FILIAL, CO1.CO1_CODEDT, CO1.CO1_NUMPRO, 
		CO1.CO1_ETAPA, SX5.X5_DESCRI  
	FROM %table:CO1% CO1
		INNER JOIN %table:SX5% SX5 ON SX5.X5_CHAVE = CO1.CO1_ETAPA 
		AND SX5.X5_FILIAL = CO1.CO1_FILIAL
		WHERE SX5.X5_TABELA = 'LE'
		ORDER BY CO1.CO1_FILIAL,CO1.CO1_CODEDT,CO1.CO1_NUMPRO,CO1.CO1_ETAPA
EndSql		
		
	While (cAliasSql)->(!EOF())
    	RecLock("CO7",.T.)
		CO7->CO7_FILIAL := xFilial('CO7',(cAliasSql)->CO1_FILIAL)
		CO7->CO7_CODEDT := (cAliasSql)->CO1_CODEDT
		CO7->CO7_NUMPRO := (cAliasSql)->CO1_NUMPRO
		CO7->CO7_ETAPA  := (cAliasSql)->CO1_ETAPA
		CO7->CO7_DESETA := (cAliasSql)->X5_DESCRI
		CO7->CO7_DTMOV  := dDataBase
		CO7->CO7_HRMOV  := cTime
		CO7->CO7_CODUSU := cUser
		CO7->(MsUnlock())	         
			
		(cAliasSql)->(dbSkip())
	EndDo

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} PopularCO2()
Função que popula alguns campos da CO2. Transcrever informações de um campo para outro.

@author Taniel Balsanelli
@since 10/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopularCO2()
Local cQuery := ""

//Update 1
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO2")+""
cQuery += " SET CO2_QTSEGU = CO2_QUANT2 "
TCSQLExec(cQuery)  

If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Popula alguns campos da CO2 " + TCSQLError())
EndIf

//Update 2
cQuery := ""
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO2")+""
cQuery += " SET CO2_SEGUM = CO2_UM2 "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Popula alguns campos da CO2 " + TCSQLError())
EndIf
     
//Update 3 - 1=Habilitado;2=Revogado;3=Anulado;4=Remanescente
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO2")+""
cQuery += " SET CO2_STATUS = '1' "
cQuery += " WHERE "
cQuery += " CO2_STATUS = ' ' "
cQuery += " AND D_E_L_E_T_ = ' ' " 

TCSQLExec(cQuery)  

If TcSqlExec(cQuery)  < 0
	conout("Update 3 - Tornar o Item para Habilitado " + TCSQLError())
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopularCP4()
Função que popula alguns campos da CP4 em caso da solicitação de compra associada ao edital. 

@author Taniel Balsanelli
@since 13/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopularCP4()
Local cAliasSql   := ""
Local cCodEdt     := ''
Local cNumPro     := ''
Local cCodFil     := ''

cAliasSql	:= GetNextAlias()

BeginSQL Alias cAliasSql
	
	SELECT 
	    SC.C1_FILIAL, SC.C1_CODED,     
        SC.C1_NUMPR, SC.C1_PRODUTO,  
        SC.C1_NUM, SC.C1_ITEM 
	FROM %table:SC1% SC    
		WHERE SC.C1_FILIAL = %xfilial:SC1%  
		AND SC.C1_CODED <> ' ' 	    

EndSql

While (cAliasSql)->(!EOF())
	cCodFil := (cAliasSql)->C1_FILIAL
	cCodEdt := (cAliasSql)->C1_CODED
	cNumPro := (cAliasSql)->C1_NUMPR     	
       
   	dbSelectArea("CP4")
   	CP4->(dbSetOrder(1))
   	If !(CP4->(DbSeek(xFilial('CP4')+cCodEdt+cNumPro)))
		RecLock("CP4",.T.)
		CP4->CP4_FILIAL := xFilial('CP4',cCodFil)
		CP4->CP4_CODEDT := cCodEdt
		CP4->CP4_NUMPRO := cNumPro
		CP4->CP4_CODPRO := (cAliasSql)->C1_PRODUTO
		CP4->CP4_NUMSC  := (cAliasSql)->C1_NUM
		CP4->CP4_ITEMSC := (cAliasSql)->C1_ITEM
		CP4->(MsUnlock())	         
	EndIf	
	(cAliasSql)->(dbSkip())		             
EndDo

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} SetStatCO3()
Função que popula o campo Status da tabela CO3 

@author guilherme.pimentel
@since 13/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function SetStatCO3()
Local cQuery := ''

cQuery := " update " + RetSqlName("CO3") 
cQuery += " set CO3_STATUS = case when CO3_CLASS = '1' and CO3_CLAANT = '1' THEN '5'"
cQuery += "   when CO3_CLASS <> '1' and CO3_CLAANT = '1' and CO1_REMAN = 'T' THEN '4'"
cQuery += "   Else '1'"
cQuery += "  End"
cQuery += " From "+RetSqlName("CO3")
cQuery += " inner join "+RetSqlName("CO1")+" on CO3_CODEDT = CO1_CODEDT and CO3_NUMPRO = CO1_NUMPRO"
TCSQLExec(cQuery)
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Popula o campo Status da tabela CO3 " + TCSQLError())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopuRegEtp()
Função que popula alguns campos da CP3 quando o edital é gerado por lote.  

@author Taniel Balsanelli
@since 15/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopuRegEtp()
Local oModel017 := nil
Local nX		  := 0
Local Quant	  := 0
 
//Inclusão do cabeçalho das Regras
GCP017CARGA(.T.)

//Exclusão de Limites antigos
COD->(DbGoTop())
While !COD->(Eof())
	RecLock("COD",.F.)
	COD->(dbDelete())
	MsUnLock()
	
	COD->(DbSkip())
End	

//Carregamento da nova estrutura das regras
CO0->(DbGoTop())

While !CO0->(Eof()) .And. (CO0->CO0_REGRA >= '001') .And. (CO0->CO0_REGRA <= '020')
	Quant := Quant + 1
	CO0->(dbSkip())
End 
 
CO0->(DbGoTop())

For nX := 1 To Quant	  		 
	
	If CO0->(DbSeek(xFilial("CO0")+CO0->CO0_REGRA))
		
		oModel017 := FWLoadModel("GCPA017")
		oModel017:SetOperation(MODEL_OPERATION_UPDATE)
	
		If oModel017:Activate() 
			GCP017Etap(oModel017,.T.)	
			If oModel017:VldData()  
		    	oModel017:CommitData()  
		    EndIf													
		EndIf			
	EndIf
	
	oModel017 := Nil
	CO0->(dbSkip())				 	   
Next nX   

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaBRW()
Função para montar o browse

@author Taniel Balsanelli
@since 16/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function MontaBRW()
Local oDlg			:= nil
Local oEdital		:= nil
Local oProcesso		:= nil
Local oRegra		:= nil
Local aColumns		:= {}
Local bValidEdit	:= { |lCancel,oBrowse| ValidEdit(lCancel,oBrowse,aList) }
Local nI 			:= 0
Local cRegra 		:= ''

DEFAULT	aList		:= {}

Private M->CO1_REGRA := ""

If Empty(aList)
	aList :=  EdtAberto()
EndIf

DEFINE MSDIALOG oDlg FROM 0,0 TO 600,600 PIXEL TITLE 'Editais x Regras'

DEFINE FWBROWSE oBrowse DATA ARRAY	EDITCELL bValidEdit ARRAY aList	OF oDlg

ADD COLUMN oEdital 		DATA { || aList[oBrowse:nAt][1] } TITLE "Edital" TYPE "C" SIZE 10 OF oBrowse
ADD COLUMN oProcesso	DATA { || aList[oBrowse:nAt][2] } TITLE "Numero do processo" TYPE "C" SIZE 10 OF oBrowse
ADD COLUMN oRegra 		DATA { || aList[oBrowse:nAt][3] } TITLE "Regra" TYPE "C" SIZE 5 EDIT READVAR "M->CO1_REGRA" OF oBrowse
ADD COLUMN oModalidade 	DATA { || aList[oBrowse:nAt][4] } TITLE "Modalidade" TYPE "C" SIZE 10 OF oBrowse
ADD COLUMN oDescr  		DATA { || aList[oBrowse:nAt][5] } TITLE "Descrição" TYPE "C" SIZE 30 OF oBrowse
oRegra:SetF3("CO0")


ACTIVATE FWBROWSE oBrowse  

TButton():New(280,200,'Confirmar' , oDlg,{|| If(GrvCOWCP2(aList),oDlg:End(),)},40,10,,,,.T.)
TButton():New(280,245,'Cancelar' , oDlg, {|| oDlg:End()},40,10,,,,.T.)

ACTIVATE MSDIALOG oDlg CENTERED

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc}EdtAberto()
Função pararetornar editais em aberto

@author Taniel Balsanelli
@since 16/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function EdtAberto()
Local aRet := {}
Local cAliasSql := ""

cAliasSql	:= GetNextAlias()

BeginSQL Alias cAliasSql
	
SELECT 	
	CO1.CO1_CODEDT, CO1.CO1_NUMPRO, 
	CO1.CO1_ESPECI, CO1.CO1_MODALI	
FROM %table:CO1% CO1 
	WHERE CO1.CO1_FILIAL = %xfilial:CO1%
	AND CO1.CO1_STATUS = 1 AND D_E_L_E_T_ = ' ' 
 
EndSql

While (cAliasSql)->(!EOF())	
	aAdd(aRet,{(cAliasSql)->CO1_CODEDT,(cAliasSql)->CO1_NUMPRO, Space(Len(CO1->CO1_REGRA)), (cAliasSql)->CO1_MODALI, ""})	
	(cAliasSql)->(dbSkip())
EndDo  

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}GrvCOWCP2(oBrowse)
Função para popular as etapas de acordo com as regra selecionada no edital

@author Taniel Balsanelli
@since 17/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function GrvCOWCP2(aList)
Local nX := 0
Local lRet := .T.

Local cCodEdt := ''
Local cNumPro := ''
Local cRegra  := ''
Local cModali := ''

DbSelectArea('COW')
DbSelectArea('CP2')

Begin Transaction

	For nX := 1 To Len(aList)
	    cRegra := aList[nX,REGRA] 
		If cRegra = " "
		  lRet := .F.
		  Aviso("Atenção","Favor preencher todas as regras",{"OK"},1)
		EndIf  
	
	   If lRet
			cCodEdt := aList[nX,EDITAL]
			cNumPro := aList[nX,PROCESSO]
			cRegra  := aList[nX,REGRA]
			cModali := aList[nX,MODALIDADE]					
							 
			GCPXGrvCOW(cCodEdt,cNumPro,cRegra,cModali,Space(Len(COW->COW_REVISA)))
			GCPXGrvCP2(cCodEdt,cNumPro,Space(Len(CP2->CP2_REVISA)),cRegra,cModali)	
			
			CO1->(dbSetOrder(1)) //CO1_FILIAL+CO1_CODEDT+CO1_NUMPRO+CO1_REVISA

			If CO1->(dbSeek(xFilial('CO1')+cCodEdt+cNumPro))			
				RecLock("CO1",.F.)
				CO1->CO1_REGRA := cRegra
				CO1->(MsUnlock())
			EndIf
			
		Else
		    DisarmTransaction()
		    Exit
  		EndIf    		  
	Next nX

End Transaction
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ValidEdit(lCancel,oBrowse,aList)
Função para validar edição da coluna regra

@author Taniel Balsanelli
@since 17/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Static Function ValidEdit(lCancel,oBrowse,aList)
Local lRet     := .T.

If !lCancel
	If Empty(AllTrim(M->CO1_REGRA))
		lRet := .T.	
	ElseIf CO0->(DbSeek(xFilial("CO0")+ M->CO1_REGRA))
		aList[oBrowse:nAt,oBrowse:ColPos()] := M->CO1_REGRA
		aList[oBrowse:nAt,DESCREGRA] := CO0->CO0_DSCRGR
		
		cRegra  := aList[oBrowse:nAt,REGRA]
		cCodEdt := aList[oBrowse:nAt,EDITAL]
		cModali := aList[oBrowse:nAt,MODALIDADE]
		
		aRet := A200MdTip(If(cModali=='IN','DL',cModali),cRegra,'')	
		If !(Len(aRet)) > 0
			lRet := .F.
			Aviso("Atenção","A modalidade " +cModali+ " referente ao edital: " +AllTrim(cCodEdt)+ " não consta na regra informada.",{"OK"},1)

			aList[oBrowse:nAt,oBrowse:ColPos()] := '   '
			aList[oBrowse:nAt,DESCREGRA] := '                    '	
		EndIf
		
	Else
	    lRet := .F.
		Aviso("Atenção","Regra não cadastrada!",{"OK"},1)	
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc AtuaEtapED()
Função para atualizar etapas nos editais em aberto

@author Taniel Balsanelli
@since 21/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function AtuaEtapED()
Local cQuery := ""

//update 1
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'AN' "
cQuery += " WHERE CO1_ETAPA = 'PB' "
cQuery += " AND CO1_DTPUBL = '' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 1 - Atualiza a Etapa com 'AN' " + TCSQLError())
EndIf

//update 2
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'AE' "
cQuery += " WHERE CO1_ETAPA = 'AD' "
cQuery += " OR CO1_ETAPA = 'AC' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 2 - Atualiza a Etapa com 'AE' " + TCSQLError())
EndIf
 
//update 3
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'JP' "
cQuery += " WHERE CO1_ETAPA = 'PX' "
TCSQLExec(cQuery)
                    
If TcSqlExec(cQuery)  < 0
	conout("Update 3 - Atualiza a Etapa com 'JP' " + TCSQLError())
EndIf

//update 4
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'HO' "
cQuery += " WHERE CO1_ETAPA = 'PB' "
cQuery += " AND CO1_DTENV <> '' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 4 - Atualiza a Etapa com 'HO' " + TCSQLError())
EndIf

//update 5
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'AD' "
cQuery += " WHERE CO1_ETAPA = 'AS' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 5 - Atualiza a Etapa com 'AD' " + TCSQLError())
EndIf

//update 6
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_ETAPA = 'FI' "
cQuery += " WHERE CO1_ETAPA = 'CO' "
cQuery += " OR CO1_ETAPA = 'PC' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update 6 - Atualiza a Etapa com 'FI' " + TCSQLError())
EndIf

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc PopularCP6()
Função para inserir a composição do lote na CP6

@author Taniel Balsanelli
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopularCP6()
Local cAliasSql := ""

cAliasSql	:= GetNextAlias()

BeginSQL Alias cAliasSql
	
SELECT 	
	CO3.CO3_FILIAL, CO3.CO3_CODEDT,
	CO3.CO3_NUMPRO, CO3.CO3_LOTE,
	CO3.CO3_CODIGO, CO3.CO3_LOJA,
	CO3.CO3_CODPRO, CO2.CO2_QUANT,
	CO3.CO3_VLUNIT	
FROM %table:CO3% CO3
	INNER JOIN %table:CO2% CO2 ON CO2.CO2_FILIAL = CO3.CO3_FILIAL
	AND CO2.CO2_CODEDT = CO3.CO3_CODEDT
	AND CO2.CO2_NUMPRO = CO3.CO3_NUMPRO
	AND CO2.CO2_CODPRO = CO3.CO3_CODPRO 
	WHERE CO3.CO3_FILIAL = %xfilial:CO3% 
	AND CO3.CO3_LOTE <> ' '	
	AND CO3.CO3_CLASS = '1'
	AND CO3.CO3_CLAANT = '1'		
	
EndSql 

	While (cAliasSql)->(!Eof())
    	RecLock("CP6",.T.)
		CP6->CP6_FILIAL := xFilial('CP6',(cAliasSql)->CO3_FILIAL)
		CP6->CP6_CODEDT := (cAliasSql)->CO3_CODEDT
		CP6->CP6_NUMPRO := (cAliasSql)->CO3_NUMPRO 
		CP6->CP6_LOTE   := (cAliasSql)->CO3_LOTE
		CP6->CP6_CODIGO := (cAliasSql)->CO3_CODIGO
		CP6->CP6_LOJA   := (cAliasSql)->CO3_LOJA
		CP6->CP6_CODPRO := (cAliasSql)->CO3_CODPRO
		CP6->CP6_QUANT  := (cAliasSql)->CO2_QUANT
		CP6->CP6_PRCUN := (cAliasSql)->CO3_VLUNIT		
		CP6->(MsUnlock())	 
		
		(cAliasSql)->(dbSkip())
	EndDo

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc PopularCP3()
Função para inserir na CP3.É Soma da CO2.

@author Taniel Balsanelli
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------

Function PopularCP3()
Local cAliasSql := ""
Local cQuery    := ""
Local cCodEdt 	:= ""
Local cNumPro	:= ""
Local cLote	   	:= ""
Local nVlTot	

cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_AVAL = 2 "
cQuery += " WHERE CO1_AVAL = 3 "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update - Atualiza o CO1_AVAL avaliacao por lote " + TCSQLError())
EndIf

cAliasSql	:= GetNextAlias()

BeginSQL Alias cAliasSql
	
SELECT
	CO2.CO2_FILIAL, CO2.CO2_CODEDT, 
	CO2.CO2_NUMPRO, CO2.CO2_LOTE, 
	SUM(CO2.CO2_QUANT * CO2.CO2_VLESTI) AS CO2_VLRTOT	
FROM %table:CO2% CO2
	INNER JOIN %table:CO1% CO1 ON CO1.CO1_CODEDT = CO2.CO2_CODEDT 
	AND CO1.CO1_NUMPRO = CO2.CO2_NUMPRO
	WHERE CO2.CO2_FILIAL = %xfilial:CO2%  
	AND CO2.CO2_LOTE <> ' '
	AND CO1.CO1_AVAL = '2'	
GROUP BY
	CO2.CO2_FILIAL, 
	CO2.CO2_CODEDT, 
	CO2.CO2_NUMPRO, 
	CO2.CO2_LOTE
	
EndSql

	While (cAliasSql)->(!Eof())

		// Verificar se o registro já encontra-se populado na CP3 (Lote)
		cCodEdt := (cAliasSql)->CO2_CODEDT
		cNumPro := (cAliasSql)->CO2_NUMPRO 
		cLote   := (cAliasSql)->CO2_LOTE
		nVlTot	:= (cAliasSql)->CO2_VLRTOT
			
		CP3->(dbSetOrder(1)) //CP3_FILIAL+CP3_CODEDT+CP3_NUMPRO+CP3_LOTE

		If !( CP3->(dbSeek(xFilial('CO1')+cCodEdt+cNumPro)) )
	    	RecLock("CP3",.T.)
			CP3->CP3_FILIAL := xFilial('CP3',(cAliasSql)->CO2_FILIAL)
			CP3->CP3_CODEDT := cCodEdt //(cAliasSql)->CO2_CODEDT
			CP3->CP3_NUMPRO := cNumPro //(cAliasSql)->CO2_NUMPRO 
			CP3->CP3_LOTE   := cLote   //(cAliasSql)->CO2_LOTE
			CP3->CP3_VLRTOT := nVlTot  //(cAliasSql)->CO2_VLRTOT
			CP3->CP3_VLRRJ  := 0
			CP3->CP3_STATUS := '1'
			CP3->(MsUnlock())
		EndIf	 
		
		(cAliasSql)->(dbSkip())
	EndDo

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc AtuaCP3()
Função para atualizar valores na CP3

@author Taniel Balsanelli
@since 22/01/2014
@version P12
/*/
//-------------------------------------------------------------------jn

Function AtuaVlrCP3()
cChave := ''
cNextChave := ''

CO3->(DbGoTop())
CO3->(dbSetOrder(2))

While CO3->(!Eof())
    cNextChave = CO3->CO3_CODEDT+'|'+CO3->CO3_NUMPRO+'|'+CO3->CO3_CODIGO+'|'+CO3->CO3_LOJA+'|'+CO3->CO3_LOTE
	If !Empty(CO3->CO3_Lote)
		If cChave <> cNextChave 
			cChave = cNextChave
			RecLock("CO3",.F.)
			CO3->CO3_CODPRO := ''
			CO3->CO3_VLUNIT := CO3->CO3_LANCE
			CO3->(MsUnlock())	
		Else
	    	RecLock("CO3",.F.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
	CO3->(dbSkip())		
EndDO

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc}AtuModIN
Função de atualização do Edital para substiruir a antiga modalidade Inexigibilidade.

@author guilherme.pimentel
@since 27/05/2014
@version P12
/*/
//-------------------------------------------------------------------

Function AtuModIN()
Local cQuery := ""

//update 1
cQuery := "UPDATE"
cQuery += " "+RetSqlName("CO1")+""
cQuery += " SET CO1_MODALI = 'DL', CO1_TIPO = 'IN' "
cQuery += " WHERE CO1_MODALI = 'DL' "
TCSQLExec(cQuery)

If TcSqlExec(cQuery)  < 0
	conout("Update - Atualiza a Modalidade para DL e Tipo IN " + TCSQLError())
EndIf

Return nil



//-------------------------------------------------------------------
/*/{Protheus.doc}ModalExist()
Função para retornar os tipos e modalidades já existente

@author Eduardo Dias
@since 28/03/2019
@version P12
/*/
//-------------------------------------------------------------------

Function ModalExist()
Local cQry	  		:= CriaTrab(Nil,.F.)

DEFAULT aModalid	:= {}

cQuery := "SELECT * "
cQuery += " FROM "+RetSqlName("COZ")+" COZ"
cQuery += " WHERE COZ.COZ_FILIAL='"+xFilial("COZ")+"' AND "
cQuery += " COZ.D_E_L_E_T_= ' ' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQry,.T.,.T.)

      
While (cQry)->(!EOF())	
	aAdd(aModalid,{"","",(cQry)->COZ_REGRA,(cQry)->COZ_MODALI, "", (cQry)->COZ_TIPO})	
	(cQry)->(dbSkip())
EndDo  


Return aModalid      
     

//-------------------------------------------------------------------
/*/{Protheus.doc}ModalExist()
Função para chamada das rotinas de UPDATE's

@author Eduardo Dias
@since 28/03/2019
@version P12
/*/
//-------------------------------------------------------------------
Function ExecRot1()

FWOpenXX4() 
AtuaModali() 
AtuaStatus()
AtuaCOPC()
AtuFORMLC()
AtuaCmbBox()

PopularCO7()
PopularCO2()
PopularCP4()
SetStatCO3() 
PopuRegEtp()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}ModalExist()
Função para chamada das rotinas de UPDATE's tabelas CP3, CP6 e Modalidade

@author Eduardo Dias
@since 28/03/2019
@version P12
/*/
//-------------------------------------------------------------------
Function AtuCPs

AtuaEtapED()
PopularCP6()
PopularCP3() 
AtuaVlrCP3()
AtuModIN()

Return()