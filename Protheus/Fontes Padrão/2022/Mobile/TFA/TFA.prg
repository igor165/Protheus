#INCLUDE "TFA.ch"
#include "eADVPL.ch"

//Adaptar o fonte para usar Browse
Function TFA()

Local oDlg, oMnu, oItem, oCol, oBrw //oLbx,
Local oSay, aOS := {}, nOS := 1, cDataIni := "", dDataBase := Date()
Local oData, oBtData //aDatas := {}, nData := 1,
Local oHorario, oCliente, oEnd, oTel, oContato
Local cHorario := space(20), cCliente := space(20), cContato := space(20)
Local cOS := space(20), cEnd := space(20), cTel := space(20), cNrItem := ""
Local nMeterFiles := 0
Local oSayFile, oMeterFiles
Public cEmpresa := ""

If !OpenEmp()
	Return .F.
EndIf

If !Senha()
   return nil
Endif                  

Set(_SET_DATEFORMAT,"dd/mm/yyyy")

MsgStatus(STR0001) //"Por favor, aguarde..."

//********************* Carrega lista de datas no formato dd/mm/yyyy *******************
/*	dbselectarea("DTA")
	dbsetorder(1)
	dbgotop()
	aSize(aDatas,0)
	While !Eof()
		aAdd(aDatas, Substr(DTA->DT_INI,7,2) + "/" + Substr(DTA->DT_INI,5,2) + "/" + Substr(DTA->DT_INI,1,4))
		dbskip()
	Enddo */
//**************************************************************************************

DEFINE DIALOG oDlg TITLE "TFA"

ADD MENUBAR oMnu CAPTION "Principal" of oDlg
ADD MENUITEM oItem CAPTION "Agenda" ACTION Agenda() of oMnu
ADD MENUITEM oItem CAPTION "Atendimento da OS" ACTION Atendimento(aOS, nOS, dDataBase, oData, oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem, .F.) of oMnu 
ADD MENUITEM oItem CAPTION "Apontar Itens"  ACTION Itens(cOS, cNrItem, aOS) of oMnu
ADD MENUITEM oItem CAPTION "Despesas" ACTION Despesas(cOS, cNrItem, aOS) of oMnu
ADD MENUITEM oItem CAPTION "Detalhes" ACTION Detalhes(cOS, cNrItem, aOS) of oMnu
ADD MENUITEM oItem CAPTION "Incluir OS" ACTION Atendimento(aOS, nOS, dDataBase, oData, oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem, .T.) of oMnu
ADD MENUITEM oItem CAPTION "Requisições" ACTION Requisicoes(cOS, cNrItem, aOS) of oMnu
//ADD MENUITEM oItem CAPTION "Pendências" ACTION Pendencias(cOS) of oMnu
//ADD MENUITEM oItem CAPTION "Assinaturas" ACTION Desenvolv() of oMnu
ADD MENUITEM oItem CAPTION "Sync" ACTION InitSync(oSayFile, oMeterFiles, nMeterFiles) OF oMnu
ADD MENUITEM oItem CAPTION "Fechar" ACTION CloseDialog() of oMnu

@ 50,20 SAY oSayFile PROMPT "" OF oDlg
@ 62,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlg

@ 18,02 BUTTON oBtData CAPTION "Data Atendim.:" ACTION DataAtend(oData,dDataBase,aOS,nOS,oBrw,oHorario,oCliente,oEnd,oTel,oContato,cOS,cNrItem) of oDlg
@ 18,80 GET oData VAR dDataBase READONLY NO UNDERLINE of oDlg 

//@ 18,85 COMBOBOX oData VAR nData ITEMS aDatas SIZE 70,80 ACTION SelectData(aOS,nOS,aDatas,nData,oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem) Of oDlg
@ 30,02 SAY oSay PROMPT "Horário:" BOLD of oDlg
@ 30,50 GET oHorario VAR cHorario READONLY NO UNDERLINE of oDlg 
@ 42,02 SAY oSay PROMPT "Cliente:" BOLD of oDlg   
@ 42,50 GET oCliente VAR cCliente READONLY NO UNDERLINE of oDlg 
@ 54,02 SAY oSay PROMPT "Endereço:" BOLD of oDlg
@ 54,50 GET oEnd VAR cEnd READONLY NO UNDERLINE of oDlg 
@ 66,02 SAY oSay PROMPT "Telefone:" BOLD of oDlg
@ 66,50 GET oTel VAR cTel READONLY NO UNDERLINE of oDlg 
@ 78,02 SAY oSay PROMPT "Contato:" BOLD of oDlg
@ 78,50 GET oContato VAR cContato READONLY NO UNDERLINE of oDlg 
//@ 92,02 SAY oSay PROMPT "O.S.            It.     Status" of oDlg 
//@ 104,02 LISTBOX oLbx VAR nOS ITEMS aOS SIZE 150,58 ACTION ExibeOS(aOS, nOS, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem) Of oDlg 
@ 92,02 BROWSE oBrw SIZE 153,63 ACTION ExibeOS(oBrw, aOS, nOS, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem) OF oDlg
SET BROWSE oBrw ARRAY aOS
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 1 HEADER "O.S." WIDTH 40
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 2 HEADER "Item" WIDTH 25
ADD COLUMN oCol TO oBrw ARRAY ELEMENT 3 HEADER "Status" WIDTH 60

HideControl(oSayFile)
HideControl(oMeterFiles)

SelectData(aOS,nOS,dDataBase,oBrw,oHorario,oCliente,oEnd,oTel,oContato,cOS,cNrItem)
ClearStatus()
                          	
ACTIVATE DIALOG oDlg

Return nil


/************************* Carrega a lista de OS a partir da agenda ***************************/
Function SelectData(aOS, nOS, dDataBase, oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem)

//Converte a data selecionada para o formato do campo (yyyymmdd)
//Local cDataIni := Substr(aDatas[nData],7,4) + Substr(aDatas[nData],4,2) + Substr(aDatas[nData],1,2)
Local cDataIni := DTOC(dDataBase)
Local cAgendaOS := "", cStatus := "", lExibe := .T., i:=0
cDataIni := Substr(cDataIni,7,4) + Substr(cDataIni,4,2) + Substr(cDataIni,1,2)

dbselectArea("ABB")
dbsetorder(2)
dbGoTop()
dbseek(cDataIni)

aSize(aOS,0)
While !Eof() 
	If ABB->ABB_DTINI == cDataIni
		cAgendaOS := ABB->ABB_NUMOS
		    
		dbSelectArea("AB7")
		dbSetOrder(1)
		dbSeek(cAgendaOS)
		While !Eof() .And. AB7->AB7_NUMOS == cAgendaOS
		    cNrItem := AB7->AB7_ITEM
		    cStatus := ""
		    lExibe := .T.
		    //Buscar no AB9 o status de atend.
		    dbSelectArea("AB9")
		    dbSetOrder(1)
		    dbSeek(cAgendaOS+cNrItem)
		    If AB9->(Found())
				//Alert("Achou " + cAgendaOS + cNrItem)
				cStatus := AB9->AB9_TIPO
				If cStatus == "1"
					cStatus := STR0002 //"Encerr."
				Else
				    cStatus := STR0003 //"Aberta"
				EndIf
				
				If AB9->(IsDirty())		//Nao Transmitido 
					lExibe := .T.
				Else					//Transmitido (nao pode exibir)
					lExibe := .F.
				EndIf
		    EndIf
		    
		    If lExibe 
		        //aAdd(aOS, AB7->AB7_NUMOS + " - " + AB7->AB7_ITEM + " - " + cStatus)
		        aAdd(aOS,{ AB7->AB7_NUMOS, AB7->AB7_ITEM , cStatus })
		    EndIf
		    dbSelectArea("AB7")
		    dbSkip()
	    Enddo
    EndIf
    dbSelectArea("ABB")
	dbSkip()
Enddo     

SetArray(oBrw, aOS)
ExibeOS(oBrw, aOS, nOS, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem)

Return nil       
/********************************************************************************************/


/******************************* Exibir dados da OS selecionada *****************************/
Function ExibeOS(oBrw, aOS, nOS, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem)

Local cCodcli := ""
nOS := GridRow(oBrw)

If  ( nOS > 0 .And. nOS <= Len(aOS) ) //verifica se o item escolhido e menor ou igual ao tamanho do array
    dbSelectArea("ABB")
	dbSetOrder(3)          
	dbgotop()  
	
	cNrItem := aOS[nOS,2] //Substr(aOS[nOS],10,2)
	cOS		:= aOS[nOS,1] //Substr(aOS[nOS],1,6)
	dbSeek(cOS, .t.)
	            
	SetText(oHorario, ABB->ABB_HRINI)
    
	dbSelectArea("AB6")
	dbSetOrder(1)
	dbgotop()
	dbSeek(aOS[nOS,1], .t.)	//Substr(aOS[nOS],1,6)

	cCodcli := AB6->AB6_CODCLI + AB6->AB6_LOJA
	
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbgotop()
	dbSeek(cCodcli, .t.)

	SetText(oCliente, SA1->A1_NOME)
	SetText(oEnd, SA1->A1_END)
	SetText(oTel, SA1->A1_TEL)
	SetText(oContato, SA1->A1_CONTATO)
Else        
	SetText(oHorario, Space(Len(ABB->ABB_HRINI))) 
	SetText(oCliente, Space(Len(SA1->A1_NOME))) 
	SetText(oEnd, 	  Space(Len(SA1->A1_END))) 
	SetText(oTel, 	  Space(Len(SA1->A1_TEL))) 
	SetText(oContato, Space(Len(SA1->A1_CONTATO))) 
Endif

Return nil
/********************************************************************************************/


Function DataAtend(oData,dDataBase,aOS,nOS,oBrw,oHorario,oCliente,oEnd,oTel,oContato,cOS,cNrItem)

Local dData:=Date()
If !Empty(dDataBase)
	dDataBase := SelectDate(STR0004,dDataBase) //"Sel. Data Atendim."
Else
	dDataBase := SelectDate(STR0004,dData) //"Sel. Data Atendim."
EndIf
SetText(oData,dDataBase)
SelectData(aOS,nOS,dDataBase,oBrw, oHorario, oCliente, oEnd, oTel, oContato, cOS, cNrItem)

Return nil