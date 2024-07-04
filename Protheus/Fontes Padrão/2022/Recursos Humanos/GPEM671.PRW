#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEM671.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GPEM671  ³ Autor ³ Marcelo Silveira                    ³ Data ³ 16.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Integração de Títulos - Protheus GPE x CMNET                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM671()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ GPEM670  										                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                  ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³Data      ³Issue           ³Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³±±
±±³             ³00/00/0000³                ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEM671()

Local oDlg
Local lMark    		:= .F.
Local oOk      		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK
Local oNo      		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local oChk1
Local oChk2
Local cSaldo 

Local nLi     		:= 6
Local cArq    		:= Space(250)
Local cPath   		:= OemToAnsi(STR0020)	//"Selecione o Diretório"
Local cDescTpDoc	:= ""

Private oLbx
Private lChk1 		:= .F.
Private lChk2 		:= .F.
Private lOk			:= .F.
Private aLctoFim	:= {}
Private aLog		:= {}
Private aVetor		:= {}
Private aRadio  	:= {} 
Private nRadio  	:= 1
Private nRadioF  	:= 0
Private nTpDoc		:= 00000000
Private oRadio  	:= Nil
Private oGetTip		:= Nil 
Private cPerg		:= 'GPM671'
Private cDir    	:= "C:\"
Private cCodTpDoc	:= ""
Private nSeq		:= 1

aAdd( aRadio, OemToAnsi(STR0007) )	//"Ordena por Cóodigo"
aAdd( aRadio, OemToAnsi(STR0008) )	//"Ordena por Descrição"

dbSelectArea("SED")
dbSetOrder(1)
dbSeek(xFilial("SED"))

While !Eof() .And. SED->ED_FILIAL == xFilial("SED") .And. SED->ED_MSBLQL <> "1"
   aAdd( aVetor, { 	lMark, ;
   					SED->ED_CODIGO, ;
   					SED->ED_DESCRIC })
	SED->( dbSkip() )
End


DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM 0,0 TO 530,586 OF oDlg PIXEL		//"Integração de Títulos - Protheus GPE x Sistemas Externos"
           
cTIT := OemToAnsi(STR0002)	//"Geração de arquivo de títulos da Folha Protheus  para integração CAP CMNET"
@ nLi, 006 SAY cTIT  SIZE 300, 8 PIXEL OF oDlg
                           
nLi += 19
@ nLi, 006 TO nLi+29, 200 LABEL OemToAnsi(STR0003) OF oDlg PIXEL	//"Tipo de Documento" 

nLi += 10
@ nLi,   015 MSGET oGetTip VAR nTpDoc F3 "S126" PICTURE "99999999" SIZE 50,10 PIXEL OF oDlg VALID ;		//Tipo de documento
Eval( { || nPos := fPosTab("S128",nTpDoc,"==",4), If( nPos > 0, cDescTpDoc := FTabela("S128", nPos, 5), cDescTpDoc := ""), oDlg:Refresh() } )
@ nLi+2, 070 SAY  cDescTpDoc        SIZE  180, 8 PIXEL OF oDlg	//Descricao do Tipo de Documento

nLi += 30
@ nLi, 006 TO nLi+125, 290 LABEL OemToAnsi(STR0004) OF oDlg PIXEL	//"Naturezas"
                   
nLi += 10
@ nLi, 015 LISTBOX oLbx FIELDS HEADER " ", OemToAnsi(STR0005), OemToAnsi(STR0006);	//"Código"#"Descrição"
   SIZE 190,107 OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1])

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                       aVetor[oLbx:nAt,2],;
                       aVetor[oLbx:nAt,3]}}

nLi += 20
@ nLi, 210 RADIO oRadio VAR nRadio ITEMS aRadio[1],aRadio[2] SIZE 70,7 PIXEL OF oDlg ON CHANGE ;	//"Ordena por Cóodigo"#"Ordena por Descrição"
         ( If(nRadio==1, aSort( aVetor,,, {|x,y| x[2]+x[3] < y[2]+y[3]}), aSort( aVetor,,, {|x,y| x[3]+x[2] < y[3]+y[2]}) ),oLbx:Refresh() )

nLi += 40
@ nLi, 210 CHECKBOX oChk1 VAR lChk1 PROMPT OemToAnsi(STR0009) SIZE 70,7 PIXEL OF oDlg ;		//"Marca/Desmarca Todos"
         ON CLICK( aEval( aVetor, {|x| x[1] := lChk1 } ),oLbx:Refresh() )

nLi += 10
@ nLi, 210 CHECKBOX oChk2 VAR lChk2 PROMPT OemToAnsi(STR0010) SIZE 70,7 PIXEL OF oDlg ;		//"Inverter a seleção"
         ON CLICK( aEval( aVetor, {|x| x[1] := !x[1] } ), oLbx:Refresh() ) 

nLi += 50
@ nLi, 015 RADIO oRadio VAR nRadioF ITEMS OemToAnsi(STR0030),OemToAnsi(STR0012) SIZE 80,7 PIXEL OF oDlg	//"Consolidar por Fornecedor"#"Agrupar por Filial"

nLi += 25
@ nLi, 015 SAY OemToAnsi(STR0013)  SIZE 065, 08 PIXEL OF oDlg	//"Destino:"
@ nLi, 038 MSGET cDir PICTURE "@!" SIZE 180, 10 PIXEL OF oDlg
@ nLi, 220 BUTTON "..."            SIZE 013, 13 PIXEL OF oDlg ACTION cDir:=cGetFile("",cPath,0,,.T.,GETF_LOCALHARD + GETF_RETDIRECTORY)

nLi += 20    
bSet15 := {|| If( fValCpos( nTpDoc, aVetor, cDir, cDescTpDoc), lOk := gpm671Processa(), Nil), If( lOk, oDlg:End(), Nil ) }
bSet24 := {|| oDlg:End()}

@ nLi, 158 BUTTON OemToAnsi(STR0021) SIZE 36, 16 PIXEL ACTION Pergunte(cPerg,.T. )	//"Parâmetros"
@ nLi, 205 BUTTON OemToAnsi(STR0022) SIZE 36, 16 PIXEL ACTION eval(bSet15)			//"Executar"   
@ nLi, 252 BUTTON OemToAnsi(STR0023) SIZE 36, 16 PIXEL ACTION oDlg:End()			//"Cancelar"

ACTIVATE MSDIALOG oDlg CENTER

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³gpm671Processa  ³ Autor ³ M. Silveira     ³ Data ³ 11.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa os titulos da tabela RC1			              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function gpm671Processa()

Local cAliasQry := GetNextAlias()
Local cWhere 	:= ""
Local cDtPagto	:= ""
Local nX		:= 0
Local nI		:= 0
Local nIni		:= 0
Local aRecRC1	:= {}
Local aLogAux := {}
Local aLcto		:= {}
Local aNatur	:= {}
Local cNatur  := ""
Local lOk := .T.

Aeval( aVetor, { |x| If( X[1], cNatur += x[2] , "")} )

cNatur := fSqlIn(cNatur,TamSx3("ED_CODIGO")[1])

Pergunte(cPerg,.F.)
MakeSqlExpr(cPerg)

//Filial
If !Empty(MV_PAR01)
	cWhere := MV_PAR01
Endif

//Centro de Custo
If !Empty(MV_PAR02)
	cWhere += If( Empty(cWhere), "", " AND " ) + MV_PAR02
Endif

//Codigos dos Titulos
If !Empty(MV_PAR03)
	cWhere += If( Empty(cWhere), "", " AND " ) + MV_PAR03
Endif
         
//Competencia
If !Empty(MV_PAR04)
	cWhere += If( Empty(cWhere), "", " AND ") + " RC1.RC1_COMPET = " + ( Substr(MV_PAR04,5,2) + Substr(MV_PAR04,1,4) )
Endif

//Data de pagamento
If !Empty(MV_PAR05)
	cDtPagto :=	cValToChar(MV_PAR05)
EndIf

//Naturezas
If ((!Empty(cNatur)) .AND. (cNatur <> "'          '"))
	cWhere += If( Empty(cWhere), "", " AND " ) + " RC1.RC1_NATURE IN (" + cNatur + ") "
EndIf

cWhere := "%" + cWhere + "%"

BeginSql alias cAliasQry
   	SELECT * FROM %table:RC1% RC1
	WHERE %exp:cWhere% AND RC1_INTEGR = 0 AND RC1.%notDel%
	ORDER BY RC1_FILIAL, RC1_FILTIT, RC1_FORNEC, RC1_NATURE
EndSql

While ( (cAliasQry)->( !Eof() ) )
    
	cDtVecto :=	If( !Empty(cDtPagto), cDtPagto, cValToChar(sToD((cAliasQry)->RC1_VENCTO)) ) //Data de Vencimento
	cDtProg  :=	If( !Empty(cDtPagto), cDtPagto, cValToChar(sToD((cAliasQry)->RC1_VENREA)) ) //Data Programada

	//Os 6 primeiros elementos sao utilizados somente para controle e ordenacao do array para geracao do arquivo
	Aadd( ;
		aLcto, { ;
				(cAliasQry)->RC1_FILIAL,;						//01 - FILIAL
				(cAliasQry)->RC1_FILTIT,;						//02 - FILIAL DO TITULO
				(cAliasQry)->RC1_CC,;							//03 - CENTRO DE CUSTO
				(cAliasQry)->RC1_FORNEC,;						//04 - FORNECEDOR
				(cAliasQry)->RC1_NATURE,;						//05 - NATUREZA
				(cAliasQry)->R_E_C_N_O_,;						//06 - RECNO
				"",;								   			//07 - Contas Caixa x Tipo de Pagamento
				StrZero(Val((cAliasQry)->RC1_FORNEC),8),;		//08 - Codigo do fornecedor
				"3",;								   			//09 - 3 = CAP (Contas a Pagar)
				cValToChar(nTpDoc),;				   			//10 - Codigo do Tipo de Documento (Tabela S128)
				"P",;								   			//11 - Indicacao de Pagamento
				"",;								   			//12 - Numero do Documento
				"",;											//13 - Complemento do Documento (Nao usado)
				cValToChar(sToD((cAliasQry)->RC1_EMISSA)),;	//14 - Data de Emissão
				cDtVecto,;										//15 - Data de Vencimento
				cDtProg,;										//16 - Data Programada
				"2"	,;											//17 - Operacao
				"00000000",;									//18 - Codigo do Alterador (Nao usado)
				cValToChar(sToD((cAliasQry)->RC1_EMISSA)),;	//19 - Data Lançamento
				(cAliasQry)->RC1_VALOR,;						//20 - Valor do Lançamento (TOTAL)
				"02",;											//21 - Operacao do Lançamento
				(cAliasQry)->RC1_NATURE	,;						//22 - Codigo do Desembolso (Natureza)
				"P",;											//23 - Indica Pagamento ou Recebimento
				"9999999999",;  								//24 - Indicação do Centro de Responsabilidade
				"",;											//25 - Indicação da Ativ./Proj.
				(cAliasQry)->RC1_VALOR,;						//26 - Valor do Rateio (CADA LANCAMENTO)
				"N",;											//27 - Contabiliza
				"",;											//28 - Codigo da Forma de Pagamento (Nao usado)
				(cAliasQry)->RC1_CC	,;							//29 - Centro de Custo para Baixa
				"Integração Folha Protheus",;					//30 - Histórico do Lançamento
				"",;											//31 - Campo em branco (Nao usado)
				"",;											//32 - Codigo Correspondente (Nao usado)
				"";												//33 - Texto de olho no imposto (Nao usado)
			} )

	(cAliasQry)->( DbSkip() )
EndDo

If Len(aLcto) > 0
	GerarArq( aLcto )
Else
	MsgAlert( OemToAnsi(STR0024) ) //"Não foram encontrados títulos que atendam aos parâmetros informados"
	lOk := .F.
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Atualiza os titulos na tabela RC1                                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If Len(aLctoFim) > 0
	(cAliasQry)->( dbCloseArea() )

	//O numero do documento tem 15 caracteres e eh gravado no campo RC1_TITEXT que no padrao possui tamanho 13.
	//Ajusta a gravacao para nao cortar o codigo e desconsiderar somente os primeiros caracteres que sao zeros
	nIni := 1
	If TAMSX3("RC1_TITEXT")[1] < 15
		nIni := 15 - TAMSX3("RC1_TITEXT")[1] + 1
	EndIf

	dbSelectArea("RC1")
	For nX :=1 to Len(aLctoFim)
		RC1->( dbGoto(aLctoFim[nX,6]) )
		RC1->(Reclock("RC1",.F.))
			RC1->RC1_INTEGR := "1"
			RC1->RC1_TITEXT := SubStr(aLctoFim[nX,12],nIni,15)
	   	RC1->(MsUnlock())
	Next nX
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Geracao do LOG com os registros processados                         ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
If Len(aLog) > 0
	cMsg := OemToAnsi(STR0014) + CRLF + CRLF 	//"Arquivo gerado com sucesso!"
	cMsg += OemToAnsi(STR0015)	//"Deseja imprimir o Log com os registros processados?"
	If MsgNoYes(cMsg,OemToAnsi(STR0016))	//"Log de processamento"
		aLogAux := {}
		aTitle  := {}
		For nX := 1 To Len(aLog)
			If nX == 1
				aAdd( aTitle, "Filial      C. For.   Nome                                      C. Custos    Natureza       Num. Documento            Valor Lcto.             Valor Rateio " )
			EndIf
			cNome := fDesc( "SA2", aLog[nX,4], "A2_NOME" )
			aAdd( 	aLogAux, { cValToChar(aLog[nX,2]) + Space(10 - Len(cValToChar(aLog[nX,2]))) ;
					+ "- " + ;			//Filial
					cValToChar(aLog[nX,4]) + Space(10 - Len(cValToChar(aLog[nX,2]))) ; //Codigo Fornecedor
					+ "- " + ;												
					cNome + Space(30 - Len(cNome)) ;											//Nome do Fornecedor
					+ "- " + ;												
					cValToChar(aLog[nX,3]) + Space(11 - Len(cValToChar(aLog[nX,3]))) ;	//Centro de Custos
					+ "- " + ;						
					cValToChar(aLog[nX,5]) + Space(12 - Len(cValToChar(aLog[nX,3]))) ;	//Natureza
					+ "- " + ;						
					cValToChar(aLog[nX,12]) + Space(20 - Len(cValToChar(aLog[nX,12]))) ;	//Numero do Documento
					+ "- " + ;					
					Transform(aLog[nX,26],"@E 999,999,999.99") + Space(10) ;	//Valor do Rateio
					+ "- " + ;	
					Transform(aLog[nX,20],"@E 999,999,999.99") } )	//Valor do Lancamento
		Next nX
		fMakeLog(aLogAux,aTitle,,,OemToAnsi(STR0028),OemToAnsi(STR0027),"G","L",,.F.) //"LOG_INTEG_Titulos_CMNET"#"Log de processamento
	EndIf
EndIf

Return(lOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GerarArq  ³ Autor ³ M. Silveira           ³ Data ³ 11.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo CSV com os titulos na tabela RC1			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function GerarArq( aTexto, cNomArq )

Local nI
Local nX
Local nHdlArq	:= 0
Local cTexto    := ""
Local cChave    := ""
Local cUltFil	:= ""
Local aAux		:= {}

If nRadioF == 2
	//Agrupamento por Filial - Documento diferente para cada -> FILIAL | FORNECEDOR | NATUREZA
	aSort( aTexto,,, {|x,y| x[1]+x[2]+x[4]+x[5] < y[1]+y[2]+y[4]+y[5]} )	
	cVar1 := "{ || aTexto[nX,1]+aTexto[nX,2]+aTexto[nX,4]+aTexto[nX,5] }"

ElseIf nRadioF == 1
	//Consolidar por Fornecedor - Documento diferente para cada -> FILIAL | FORNECEDOR
	aSort( aTexto,,, {|x,y| x[1]+x[2]+x[4] < y[1]+y[2]+y[4]} )
	cVar1 := "{ || aTexto[nX,1]+aTexto[nX,2]+aTexto[nX,4] }"
Else
	//Nenhuma opcao selecionada - Documento diferente para cada -> FILIAL | FORNECEDOR | NATUREZA | CC
	aSort( aTexto,,, {|x,y| x[1]+x[2]+x[4]+x[5]+x[3] < y[1]+y[2]+y[4]+y[5]+y[3]} )	
	cVar1 := "{ || aTexto[nX,1]+aTexto[nX,2]+aTexto[nX,4]+aTexto[nX,5]+aTexto[nX,3] }"	
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Atualiza o array final e gera o numero do documento                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
For nX := 1 To Len(aTexto)
	If !Empty(cChave) 
		If cChave == eval( &cVar1 )
			aAdd( aAux, aTexto[nX] )
		Else
			fAcumula( aAux ) 
			aAux   := Array(0)			
			cChave := eval( &cVar1 )
			aAdd( aAux, aTexto[nX] )
		EndIf
	Else
		cChave := eval( &cVar1 )
		aAdd( aAux, aTexto[nX] )
	EndIf
Next nX 

If Len(aAux) > 0
	fAcumula( aAux ) 
EndIf

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Gera o arquivo CSV                                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
For nX := 1 To Len(aLctoFim)
                             
	If aLctoFim[nX,2] # cUltFil
	
		//Fecha o arquivo existente na mudanca de Filial
		If !Empty( cUltFil )
			FClose(nHdlArq)
		EndIf

		cUltFil := aLctoFim[nX,2]		
		cNumArq	:= dToS( dDatabase ) + StrTran( cValToChar( Time() ), ":", "") + "1"
		cNomArq	:= "CAPFOL_" + AllTrim(cUltFil) + "_" + SubStr(cNumArq,1,4) + "_" + SubStr(cNumArq,5,2) + "_" + SubStr(cNumArq,7,2) + "_" + SubStr(cNumArq,9,4) 
		cArquivo:= cDir+cNomArq + ".csv"

		//Gera um novo arquivo inicio do processamento ou na mudanca de Filial
		nHdlArq := fCreate(cArquivo)
	EndIf

	For nI := 1 To Len( aLctoFim[nX] )
		//nao considera os 6 primeiros campos porque eles sao usados para controle
		If nI >= 7
			If( nI == 20 .Or. nI == 26 ) //Trata os campos de valores
				cTxtAux := AllTrim( Transform(aLctoFim[nX,nI], "@R 99999999999999.99") )
				cTexto  += Replicate( "0", 17-Len(cTxtAux) ) + cTxtAux + "," 
			Else
				cTexto += cValToChar(aLctoFim[nX,nI]) + ","
			EndIf
		EndIf
	Next nI

	fWrite(nHdlArq, cTexto + CHR(13)+CHR(10) )
	cTexto := ""
	aAdd( aLog, aLctoFim[nX] )
	
	cUltFil := aLctoFim[nX,2]
	
Next nX

FClose(nHdlArq)

Return()
           
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fAcumula  ³ Autor ³ M. Silveira           ³ Data ³ 11.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo CSV com os titulos na tabela RC1			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fAcumula( aDados )

Local nX	  := 0
Local nValTot := 0
Local cTime	  := StrTran( cValToChar( Time() ), ":", "") + "0"  	//HHMMSS + "0"
Local cNumDoc := SubStr( dToS(dDatabase),3,8) + cTime			//AAMMDD + HHMMSS + "0" = 13 digitos

cNumDoc := StrZero( (Val(cNumDoc)+nSeq), 15 ) //Garante não gerar números repetidos e ajusta em 15 o tamanho para o sistema CMNET com zeros no inicio

//Obtem o valor total considerando todos os lancamentos do mesmo documento
For nX := 1 To Len( aDados )
	nValTot += aDados[nX,26]
Next nX

//Atualiza o campo valor do lancamento com total de todos os registros que terao o mesmo documento
For nX := 1 To Len( aDados )
	aDados[nX,20] := nValTot
	aDados[nX,12] := cNumDoc
Next nX

//Adiciona o registro na matriz final com os dados prontos para geracao do arquivo	
For nX := 1 To Len( aDados )
	aAdd( aLctoFim, aDados[nX] )
Next nX	

nSeq ++

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GerarArq  ³ Autor ³ M. Silveira           ³ Data ³ 11.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera o arquivo CSV com os titulos na tabela RC1			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fValCpos(nTipoDoc, aNatureza, cDiretorio, cDescTp)
         
Local lRet   := .T.
Local nCount := 0
Local cMsgVal := ""

DEFAULT nTipoDoc	:= ""
DEFAULT aNatureza	:= {}
DEFAULT cDiretorio	:= ""

If lRet .And. Empty(nTipoDoc) .Or. nTipoDoc == 0
	cMsgVal := OemToAnsi(STR0017)	//"Informe o Tipo de Documento."
	lRet := .F.
EndIf

If lRet .And. Empty(cDescTp)
	cMsgVal := OemToAnsi(STR0029)	//Informe ou selecione um Tipo de Documento válido.
	lRet := .F.
EndIf

If lRet .And. !Empty(aNatureza)
	Aeval( aNatureza, { |x| If( X[1], nCount ++, "")} )
	If nCount == 0
		cMsgVal := OemToAnsi(STR0018) 	//"Selecione uma ou mais Natureza para filtro dos titulos."
		lRet := .F.
	EndIf
EndIf
     
If lRet .And. Empty(cDiretorio)
	cMsgVal := OemToAnsi(STR0019)		//"Selecione o diretório para geração do arquivo."
	lRet := .F.
EndIf

Pergunte(cPerg,.F.)
If lRet .And. Empty(MV_PAR04)
	cMsgVal := OemToAnsi(STR0025)	//"Informe a competência para pesquisa dos títulos"
	lRet := .F.	
EndIf

If !Empty( cMsgVal )
	MsgAlert( cMsgVal, OemToAnsi(STR0026) ) //"Selecione uma ou mais Natureza para filtro dos titulos."#"Atenção"
EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ fChkGp671³ Autor ³ M. Silveira		    ³ Data ³ 11.05.17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a Competencia	informada							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fChkGp671()

Local cMesAno := &(Alltrim(ReadVar()))
Local lRet    := .T.

If lRet .And. Len(AllTrim(cMesAno)) <> 6
	Help(" ",1,"XINVANOMES") //"Período inválido."#Favor preencher mês e ano no formato: AAAAMM. Ex.: 201701.
	lRet := .F.
EndIf
If lRet .And. ( Empty(cMesAno) .OR. Val(Right(Alltrim(cMesAno),2)) < 1 .OR. Val(Right(cMesAno,2)) > 12 )
	Help(" ",1,"XINVANOMES") //"Período inválido."#Favor preencher mês e ano no formato: AAAAMM. Ex.: 201701.
	lRet := .F.
EndIf

Return( lRet )