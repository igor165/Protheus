#INCLUDE "QNCA160.CH"
#INCLUDE "PROTHEUS.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QNCA160Eta ³ Autor ³ Leandro			        ³ Data ³ 21/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Amarracao da Etapa x Plano x Habilidade, chamado via QNCA050      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QNCA160Eta( nOpc )                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ nOpc       ³ Opcao de selecao do aRotina                          ³±±
±±³Uso		  ³ Generico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCA160 (nOpc,cEtapa, ordem)
Local oDlg1   
Local nCnt
Local cDescEtapa:= Posicione('QID',1,xFilial('QID')+AllTrim(cEtapa),'QID_DESCTP')
Local oCodigo, oRevisao, oEtapa
Local nI        := 0 
Local nOpcA     := 0
Local aArea     := GetArea()   
Local nT        := 0
Local lOk       := .F.
 
Private cCodigo   := M->QI3_CODIGO
Private cRevisao  := M->QI3_REV
Private aTELA[0][0]
Private aGETS[0]
Private aHeader := {}
Private aCols   := {}
Private oGet1       

Default nOpc := 2

QNC160FGet(nOpcA,cEtapa)

nUsado := Len(aHeader)                                  

DEFINE MSDIALOG oDlg1 TITLE OemToAnsi(STR0001) FROM 009,000 TO 028,080 OF oMainWnd // "Cadastro de Etapa do Plano x Habilidade"
       	
@ 016,002 TO 043,314 OF oDlg1 PIXEL
                                                                                                              
@ 020,008 SAY OemToAnsi(STR0002) SIZE 35,07   OF oDlg1 PIXEL //"Codigo Acao:"
@ 020,045 MSGET oCodigo VAR cCodigo          SIZE  50, 8 OF oDlg1 PIXEL

@ 020,100 SAY OemToAnsi(STR0003) SIZE 35,07   OF oDlg1 PIXEL//"Revisao:"
@ 020,133 MSGET oRevisao VAR cRevisao        SIZE 03, 08 OF oDlg1 PIXEL 

@ 032,010 SAY OemToAnsi(STR0004) SIZE 30,07   OF oDlg1 PIXEL//"Etapa"
@ 031,045 MSGET oEtapa VAR cDescEtapa   SIZE 100, 08 OF oDlg1 PIXEL 

oCodigo:lReadOnly  := .T.
oRevisao:lReadOnly := .T. 
oEtapa:lReadOnly   := .T. 

oGet1 :=MsNewGetDados():New(046, 001, 136, 315,Iif(Altera .Or. Inclui,GD_INSERT+GD_DELETE+GD_UPDATE,0),"QN160LinOk(oGet1:nAt)",,,,,,,,,oDlg1,aHeader,aCols) //"AllwaysTrue()"
//oGet1   := MSGetDados():New( 046, 001, 136, 315, nOpc ,"QN160LinOk()",  ,  ,.F.,,,,,,,,,oDlg1)

ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar( oDlg1,{||aCols := oGet1:aCols,lOk := IIF(QN160LinOk(),(aCols := oGet1:aCols,oDlg1:End()),.F.)},{|| lOk := .F.,oDlg1:End()}) CENTERED

If lOk
   QNC160GrQUR(aCols,aHeader,cEtapa)
Endif	
                                              
RestArea(aArea)

n:= ordem

Return 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QN160LinOk ³ Autor ³ Leandro			        ³ Data ³ 21/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Critica Linha Digitada                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QN160LinOk()                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ Nao tem    ³                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ Generico                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QN160LinOk(nLin)
Local nx
Local lRet     := .T.
Local nPosHabil:= Ascan(aHeader,{|x| x[2] = "QUR_HABIL"})
Local cProcura := ""
Local nAchou   := 0

Default nLin := 1
                    
cProcura := aCols[nLin,nPosHabil]

If aCols[nLin, nUsado + 1 ]  = .f.
   For nx = 1 To Len(aHeader) - 2 
       If Empty( aCols[ nLin ][ nx ] ) 
          If Lastkey() # 27                                                                           		
             MsgAlert(STR0005)//"Existem campos obrigatorios em branco"
             lRet := .F.                
          EndIf
          Exit
       EndIf
   Next nx
EndIf

nAchou := Ascan(aCols,{|x| x[nPosHabil] == cProcura .And. !(x[Len(aCols[nLin])])})
If nAchou > 0 .And. nAchou # nLin
	MsgAlert(STR0006)//"Habilidade ja realacionada a esta Etapa"
	lRet:=.F.
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QNC160Get  ³ Autor ³ Leandro            ³ Data ³ 21/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Monta aHeader e Acols do Cadastro de Etapas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ QNC160FGet(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpN1 - nOpc  											  ³±±
±±³			  ³	Etapa - Etapa da QI5                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QNCA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC160FGet(nOpc,cEtapa)
Local cSeek
Local cWhile                                                          
Local lInclui := .F.
Local nFilial, nMat
Local nx
                                                                             
dbSelectArea("QUR")
dbSetOrder(1)

If !DbSeek(xFilial("QUR")+cCODIGO)
	lInclui := .T.
EndIf                                                                        

/*
If !Empty(QI5->QI5_CODIGO)
	cSeek  := QI5->QI5_FILIAL+QI5->QI5_CODIGO+AllTrim(cEtapa)
	cWhile := "QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO"
Else
	cSeek  := xFilial("QUR")+M->QI3_CODIGO+cEtapa                                      
	cWhile := "QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO"
Endif
*/

cSeek  := xFilial("QUR")+M->QI3_CODIGO+cEtapa                                      
cWhile := "QUR->QUR_FILIAL+QUR->QUR_CODIGO+QUR->QUR_TPACAO"

If lInclui
	  FillGetDados(3,"QUR" ,1     ,       ,           ,         ,{"QUR_CODIGO","QUR_DESETA","QUR_TPACAO"},          ,        ,      ,        ,lInclui ,          ,        ,          ,           ,            ,)
Else
	FillGetDados(4   ,"QUR" ,1     ,cSeek ,{|| &cWhile},         ,{"QUR_CODIGO","QUR_DESETA","QUR_TPACAO"},          ,        ,      ,        ,       ,          ,        ,          ,           ,            ,) //{"QUR_CODIGO","QUR_DESETA","QUR_TPACAO"}
    //FillGetDados(nOpc,Alias ,nOrdem,cSeek  ,bSeekWhile  ,uSeekFor ,aNoFields                                ,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty ,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry
EndIf

//Forca a descricao da habilidade, caso nao traga da fillgetdados...
For nx := 1 To Len(aCols)
	dbSelectArea("RBG")
	dbSetOrder(1)
	If dbSeek(xFilial("RBG")+aCols[nx,1])  
		aCols[nx,2] := RBG->RBG_DESC
	Endif
Next


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	  ³ QNC160GrQUR³ Autor ³ Leandro            ³ Data ³ 21/02/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao  ³ Grava array com os subcadastros                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ Qnc160GrQUR(ExpA1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpA1 - Array contendo as informacoes iniciais do Acols   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		  ³ QNCA160                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNC160GrQUR(AcolsAux,aHeadNiv,cEtapa)
Local nCnt  := 0
Local nCpo

DbSelectArea("QUR")
DbSetOrder(2)

For nCnt:= 1 To Len(AcolsAux)
	If !AcolsAux[nCnt,nUsado+1] // Verifica se o item foi deletado
		If QUR->(DbSeek( QUR->QUR_FILIAL+AllTrim(cCodigo)+Alltrim(cEtapa)+AllTrim(AcolsAux[nCnt,1])))
			RecLock("QUR",.F.)
		Else
			If !Empty(AcolsAux[nCnt,1])//Habilidade
				RecLock("QUR",.T.)
				QUR->QUR_FILIAL := xFilial("QUR")
				QUR->QUR_CODIGO := cCodigo
				QUR->QUR_TPACAO := Alltrim(cEtapa)  	   	
			Endif	
		End	
		For nCpo := 1 To Len(aHeadNiv)
			If aHeadNiv[nCpo, 10] # "V"
				QUR->(FieldPut(FieldPos(Trim(aHeadNiv[nCpo,2])),AcolsAux[nCnt,nCpo]))
			EndIf
		Next nCpo		
		MsUnLock()
	Else                                    
		If QUR->(DbSeek( QUR->QUR_FILIAL + QUR->QUR_CODIGO+ QUR->QUR_TPACAO + QUR->QUR_HABIL))
			RecLock("QUR",.F.)
			dbDelete()
			MsUnlock()			
		Endif	
	Endif   
	FKCOMMIT()
Next nCnt

Return	
