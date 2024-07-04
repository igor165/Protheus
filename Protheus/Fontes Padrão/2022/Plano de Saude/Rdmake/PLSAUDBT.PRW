#INCLUDE "RWMAKE.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PLSMGER.CH'
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSAUDBT  Ё Autor Ё Totvs					Ё Data Ё 07/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Retorna a titulo do menu e nome da funcao a ser executada  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSAUDBT()
Return( {"Part HonorАrios MИdicos Itens","U_PLSAUDMS"} )
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLAUDCUS  Ё Autor Ё Totvs					Ё Data Ё 07/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Criar funcao para acao do ponto de entrada				  Ё╠╠╠
╠╠Ё			 Ё O nome desta funcao deve ser retornado pelo rdmake		  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function PLSAUDMS()
LOCAL nFor		:= 1
LOCAL cCodOpe 	:= B53->B53_CODOPE
LOCAL cCodLdp 	:= B53->B53_CODLDP
LOCAL cCodPeg 	:= B53->B53_CODPEG
LOCAL cNumero 	:= B53->B53_NUMERO
LOCAL cOriMov 	:= B53->B53_ORIMOV          
LOCAL cLin1		:= 008.0
LOCAL cLin2		:= 034.4
LOCAL cCol1		:= 010.3
LOCAL cCol2		:= 100.3
LOCAL oDlg		:= NIL
LOCAL bOK		:= {|| oDlg:End() }
LOCAL bCancel	:= {|| oDlg:End() }
LOCAL aButtons	:= {}
LOCAL cSQL		:= ""
LOCAL aCabec    := {{"Oper.","@!",20},{"Loc.Dig.","@!",30},{"Peg","@!",30},{"Num.","@!",30},{"Seq.","@!",20},{"Tip.Tab.","@!",20},{"Cod.Proc.","@!",30} ,{"Desc.Proc.","@!",200}}
LOCAL aDados	:= {}

If (B53->B53_ROTGEN == "1")
	Alert ("OpГЦo nЦo disponМvel para Rotina GenИrica")//colocar str
	Return
EndIf

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Select no BD6
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
cSQL := " SELECT * FROM " + BD6->(RetSQLName("BD6"))
cSQL += "  WHERE BD6_FILIAL = '" + xFilial("BD6") + "' "
cSQL += "    AND BD6_CODOPE = '" + cCodOpe + "' "
cSQL += "    AND BD6_CODLDP = '" + cCodLdp + "' "
cSQL += "    AND BD6_CODPEG = '" + cCodPeg + "' "
cSQL += "    AND BD6_NUMERO = '" + cNumero + "' "
cSQL += "    AND BD6_ORIMOV = '" + cOriMov + "' "
cSQL += "    AND D_E_L_E_T_ = ' ' "
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRB",.F.,.T.)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifica se tem registro
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Do While !TRB->( Eof() )

 	AaDd(aDados,{TRB->BD6_CODOPE,TRB->BD6_CODLDP,TRB->BD6_CODPEG,TRB->BD6_NUMERO,TRB->BD6_SEQUEN,TRB->BD6_CODPAD,TRB->BD6_CODPRO,TRB->BD6_DESPRO,TRB->R_E_C_N_O_} )

TRB->( DbSkip() )
EndDo
TRB->(DbCloseArea())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Browse
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
DEFINE MSDIALOG oDlg TITLE "Part HonorАrios MИdicos Itens" FROM cLin1,cCol1 TO cLin2,cCol2                     

oObj := TcBrowse():New(022,005,345,160,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,)    

oObj:bLDblClick := { || PLSDBCLI(aDados,oObj:nAt) }

For nFor := 1 To Len(aCabec)
	bBlock := "{ || aDados[oObj:nAt, "+Str(nFor,4)+"] }"
	bBlock := &bBlock
	oObj:AddColumn(TcColumn():New(aCabec[nFor,1],bBlock,aCabec[nFor,2],nil,nil,nil,aCabec[nFor,3],.F.,.F.,nil,nil,nil,.F.,nil))
Next

oObj:SetArray(aDados)

Activate MsDialog oDlg On Init Eval({|| EnChoiceBar(oDlg,bOK,bCancel,.F.,aButtons)}) Center
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return                                                                
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    ЁPLSDBCLI  Ё Autor Ё Totvs					Ё Data Ё 07/03/11 Ё╠╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Mostra campos da tabela									  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
STATIC FUNCTION PLSDBCLI(aDados,nLin)
LOCAL I__f 		 := 0    
LOCAL nRecno	 := aDados[nLin,9]
LOCAL oEncAut 	 := NIL
LOCAL oDlg		 := NIL                            
LOCAL oGetBD7    := NIL
LOCAL cCamposBD6 := "BD6_CODPAD,BD6_CODPRO,BD6_DESPRO,BD6_QTDPRO,BD6_QTDSOL,BD6_QTDPRO,BD6_VLRAPR"
LOCAL cCamposBD7 := "BD7_SEQUEN,BD7_CODPAD,BD7_CODPRO,BD7_CODTPA,BD7_CODUNM,BD7_CODRDA,BD7_NOMRDA,BD7_FATMUL"
LOCAL aDadUsr    := PLSGETUSR()
LOCAL cPadInt	 := ""
LOCAL cRegAte	 := ""
LOCAL cPadCon	 := ""
LOCAL nFatMul	 := 0
LOCAL aValor     := {}
LOCAL aCpoEnch   := {} 
LOCAL cChave 	 := ""
LOCAL nMax       := 999
LOCAL nI,nJ      := 0
LOCAL aTrab      := {}
LOCAL aHeader    := {}
LOCAL aCols      := {}
LOCAL lInter     :=.F.

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Posiciono no registro corrente - Procedimento BD6
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BD6->(DbGoto(nRecno))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Monto o aDadUsr
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If Len(aDadUsr) == 0
	aDadUsr := PLSDADUSR(BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO),"1",.T.,BD6->BD6_DATPRO)
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Verifico Dados para o Fator Multiplicador
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
If BD6->BD6_TIPGUI == "03"// Internacao
	BE4->(dbSetOrder(1))//BE4_FILIAL, BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, BE4_SITUAC, BE4_FASE
	BE4->(MsSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE))) 
	cPadInt:= BE4->BE4_PADINT
	cRegAte:= BE4->BE4_REGINT
	cPadCon:= BE4->BE4_PADCON
	lInter:=.T.
Else
	BD5->(dbSetOrder(1))//BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA
	BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC+BD6_FASE+DTOS(BD6_DATPRO)+BD6_OPERDA+BD6_CODRDA)))
	cPadInt:= BD5->BD5_PADINT
	cRegAte:= BD5->BD5_REGINT
	cPadCon:= BD5->BD5_PADCON
Endif		   		   	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Funcao de calculo do procedimento aonde retorna o nFatMul	  			 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aValor := PLSCALCEVE(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_MESPAG,BD6->BD6_ANOPAG,BD6->BD6_CODOPE,;
					 BD6->BD6_CODRDA,BD6->BD6_CODESP,"",BD6->BD6_CODLOC,BD6->BD6_QTDPRO,BD6->BD6_DATPRO,"",;
					 cPadInt,cRegAte,0,aDadUsr,cPadCon,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
					 nil,{},nil,BD6->BD6_DATPRO,nil,nil,nil,.F.,0,nil,nil,nil,nil,;
					 nil,nil,BD6->BD6_QTDPRO,BD6->BD6_QTDPRO,"","",BD6->BD6_SEQUEN)	

aAux     := aClone(aValor[1])

If lInter .And. nFatMul > 0 .And. allTrim(BE4->BE4_REGINT) $ allTrim(getNewPar("MV_FTREGI","@"))
	nFatMul := 1
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Monto STORE FIELD
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Copy "BD6" To Memory 
STORE FIELD "BD6" TO aCpoEnch For SX3->X3_CAMPO $ cCamposBD6
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Posiciono no Item procedimento BD7
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
BD7->(dbSetOrder(2))//BD7_FILIAL, BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_CODPAD, BD7_CODPRO, BD7_CODUNM, BD7_NLANC
BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO))) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pego a chave do Item Procedimento										 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cChave := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monto aHeader e aCols													 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Copy "BD7" To Memory
STORE HEADER "BD7" TO aHeader For SX3->X3_CAMPO $ cCamposBD7
STORE COLS "BD7" TO aCols FROM aHeader VETTRAB aTrab While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) == cChave																

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualizo Fator Multiplicador											 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI:=1 To Len(aCols) 
	For nJ:= 1 To Len(aAux)
	    If Alltrim(aAux[nJ][1]) == Alltrim(aCols[nI][2]) .And. Len(aAux[nJ][5])>0
	    	aCols[nI,PLRETPOS("BD7_FATMUL",aHeader)]:= IIF(nFatMul==1,nFatMul,aAux[nJ,5,1,6])	
	    Endif
	Next nJ
Next nI

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Dialog
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
DEFINE MSDIALOG oDlg TITLE "Dados do Procedimento e Itens" FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё MsMGet
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oEncAut := BD6->(MsMGet():New("BD6",nRecno,K_Visualizar,,,,aCpoEnch,{002,001,140,355},{},,,,,oDlg,,.T.,,,.T.))
//oEncAut := BD6->(MsMGet():New("BD6",nRecno,K_Alterar,,,,aCpoEnch,{002,001,140,355},{aCpoEnch[6],aCpoEnch[5]},,,,,oDlg,,.T.,,,.T.))
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё GetDados
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
oGetBD7:= MsNewGetDados():New(142,001,200,355,K_Visualizar,,,,{},,nMax,,,,oDlg,aHeader,aCols)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Active
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
ACTIVATE MSDIALOG oDlg On Init Eval({|| EnChoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() },.F.,)}) CENTER
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
//Ё Fim da Rotina															 
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
Return
