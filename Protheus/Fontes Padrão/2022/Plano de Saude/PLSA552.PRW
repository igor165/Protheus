#INCLUDE "PLSA552.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMGER2.CH"
#INCLUDE 'MSOBJECT.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TCBROWSE.CH"
#include "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PLSA552 ³ Autor ³ Michel Montoro       	³ Data ³ 17.12.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Transferência de Atendimentos para os Contas Médicas		  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSA552()                                                   ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus 7.10                                     ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial.                              ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA552()

PRIVATE cAlias	:= "B0O"
PRIVATE aCdCores:= {	{ 'BR_VERMELHO'	,STR0012 },; 	//'Não Iniciado'
						{ 'BR_AMARELO' 	,STR0013 },; 	//'Parcialmente Transferido'
						{ 'BR_VERDE'	,STR0014 }}  	//'Totalmente Transferido'
						
PRIVATE aCores 	:= {	{ cAlias+'_STATUS = "1"',aCdCores[1,1] },;	//'Não Iniciado'
						{ cAlias+'_STATUS = "2"',aCdCores[2,1] },; //'Parcialmente Transferido'
						{ cAlias+'_STATUS = "3"',aCdCores[3,1] }}  //'Totalmente Transferido'

PRIVATE aRotina		:= MenuDef(1)
PRIVATE cCadastro	:= FunDesc() //"Transferência Processamento de Contas"
PRIVATE lSoVisual	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizar Andamentos Dos Arquivos Importados (B0O)...	 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
f552AtB0O()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o conteúdo dos parâmetros necessários para a rotina...			 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PL552VPar()
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a chamada de acordo com filtro ...                        	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := "@B0O_FILIAL = '"+xFilial(cAlias)+"' AND D_E_L_E_T_ = ' '"

DbSelectArea(cAlias)
DbSetOrder(1)
&(cAlias)->( Dbgotop() )
If &(cAlias)->( Eof() )
	MsgInfo(STR0011) //"Nenhum processo encontrado. Inclua os processos para realizar as transferências!!!"	
	Return(.F.)
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta mbrowse padrao...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSetOrder(1)
SET FILTER TO &cFiltro

&(cAlias)->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,nil,nil,nil,nil,nil,aCores,nil,nil,nil,nil,.F.,nil,nil,cFiltro))
&(cAlias)->(DbClearFilter())
SET KEY VK_F12 TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Michel Montoro        ³ Data ³17/12/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef(nTipo)
Default nTipo := 1

If nTipo == 1 		// Menu Inicial
	aRotina := { 	{ OemtoAnsi(STR0001), 'AxPesqui' 			, 0 , K_Pesquisar  , 0, .F.},; 	//"Pesquisar"
					{ OemtoAnsi(STR0006), 'PL552SEL'   			, 0 , K_Visualizar , 0, Nil},;  	//"Selecionar Processo"
					{ OemtoAnsi(STR0052), 'PL552DEL' 				, 0 , K_Visualizar , 0, Nil},;  	//"Apagar Ressarc. SUS"
					{ OemtoAnsi(STR0005), 'PL552LEG(aCdCores)' 	, 0 , K_Visualizar , 0, Nil}}   	//"Legenda"

ElseIf nTipo == 2	// Menu Selecionar
	aRotina := { 	{ OemtoAnsi(STR0001), 'AxPesqui'   			, 0 , K_Pesquisar  , 0, .F.},;  	//"Pesquisar"
					{ OemtoAnsi(STR0002), 'PLSA552VIS' 			, 0 , K_Visualizar , 0, Nil},;  	//"Visualizar"
					{ OemtoAnsi(STR0003), 'PLSA552TRF' 			, 0 , K_Incluir    , 0, Nil},;  	//"Transf. Processamento de Contas"
					{ OemtoAnsi(STR0004), 'PLSA552TLO' 			, 0 , K_Incluir    , 0, Nil},;  	//"Transferência em Lote"
					{ OemtoAnsi(STR0047), 'PLSA552ANA' 			, 0 , K_Visualizar , 0, Nil},;  	//"Analisar Incompletos"
					{ OemtoAnsi(STR0005), 'PL552LEG(aCdCore2)' 	, 0 , K_Visualizar , 0, Nil}}   	//"Legenda"   
EndIf					 
Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PL552LEG   ³ Autor ³ Michel Montoro      ³ Data ³ 14.12.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL552LEG(aBkCores,lLeg)

DEFAULT lLeg := .F.

BrwLegenda(cCadastro,IIf(lLeg,STR0005,STR0007),aBkCores) //"Legenda","Status"

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PL552DEL   | Autor ³ Totvs     		  ³ Data ³ 20.06.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para apagar ressarcimentos    	 	 			  ³±±
±±³          ³ 			                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL552DEL()
Local aRecs		:= {}
Local aRecsBCI  := {}
Local aCodpeg	:= {}
Local cPeg		:= ""
Local nI	  	:= 1
Local nPeg		:= 1
Local lRet 		:= .F.

//Recolho todos CODPEG e armazeno em aCodpeg
cAliasPeg	:= GetNextAlias()
BeginSql Alias cAliasPeg
	SELECT B0R.R_E_C_N_O_, B0R.B0R_CODPEG FROM %table:B0R% B0R
	WHERE B0R.B0R_FILIAL = %exp:xFilial("B0R")% AND 
	B0R.B0R_IDANS = %exp:B0O->B0O_IDANS% 	AND
	B0R.B0R_MESPRO = %exp:B0O->B0O_MESPRO% AND
	B0R.B0R_ANOPRO =  %exp:B0O->B0O_ANOPRO%	AND 
	B0R.%NotDel%
Endsql

While !(cAliasPeg)->(Eof())   
	If aScan(aCodpeg,{|x| x == (cAliasPeg)->B0R_CODPEG}) == 0
		aadd(aCodpeg,(cAliasPeg)->B0R_CODPEG)
	Endif  
	(cAliasPeg)->(dbSkip())   
Enddo
(cAliasPeg)->(DbCloseArea())

For nPeg:=1 To Len(aCodpeg)
	
	//Posiciono na BCI
	BCI->(DbSetOrder(14))	//BCI_FILIAL+BCI_CODPEG
	If !Empty(aCodpeg[nPeg])
		cPeg := Iif(BCI->(MsSeek(xFilial("BCI")+ aCodpeg[nPeg])),BCI->BCI_CODPEG,"")
	Endif

	cAliasTrb	:= GetNextAlias()
	BeginSql Alias cAliasTrb
		SELECT B0R.R_E_C_N_O_, B0R.B0R_CODOPE, B0R.B0R_CODRDA FROM %table:B0R% B0R
		WHERE B0R.B0R_FILIAL = %exp:xFilial("B0R")% AND 
		B0R.B0R_IDANS = %exp:B0O->B0O_IDANS% 	AND
		B0R.B0R_MESPRO = %exp:B0O->B0O_MESPRO% AND
		B0R.B0R_ANOPRO =  %exp:B0O->B0O_ANOPRO% AND
		NOT EXISTS (SELECT 1 FROM %table:BD6% BD6
					WHERE BD6_FILIAL = %exp:xFilial("BCI")%
					AND BD6_CODOPE = %exp:BCI->BCI_CODOPE%
					AND BD6_CODLDP = %exp:BCI->BCI_CODLDP%
					AND BD6_CODPEG = %exp:cPeg%
					AND BD6_FASE > '1'
					AND BD6.%NotDel%)
		AND B0R.%NotDel%
	Endsql
		
	While !(cAliasTrb)->(Eof())   
		If aScan(aRecs,{|x| x == (cAliasTrb)->R_E_C_N_O_}) == 0
			aadd(aRecs,(cAliasTrb)->R_E_C_N_O_)
		Endif  
		(cAliasTrb)->(dbSkip())   
	Enddo
	(cAliasTrb)->(DbCloseArea())
	
	If B0O->B0O_STATUS $ "2,3" //2-Parcialmene Recebido 3-Gerado Contas Medicas --> Ja possui Guias
		If MsgYesNo(STR0049,STR0048) // O processo já possui Contas Médicas Geradas. Deseja continuar? - Exclusão de Ressarcimento SUS
		
			For nI:=1 To Len(aRecs)
	
				B0R->(DbGoto(aRecs[nI]))
				
				cAliasTrb	:= GetNextAlias()
				BeginSql Alias cAliasTrb
					SELECT BCI.R_E_C_N_O_ FROM %table:BCI% BCI
					WHERE BCI.BCI_FILIAL = %exp:xFilial("BCI")% AND 
					BCI.BCI_CODOPE = %exp:B0R->B0R_CODOPE% AND
					BCI.BCI_CODRDA = %exp:B0R->B0R_CODRDA% AND
					BCI.BCI_CODPEG = %exp:B0R->B0R_CODPEG% AND
					BCI.%NotDel%
				Endsql
					
				While !(cAliasTrb)->(Eof())
					If aScan(aRecsBCI,{|x| x == (cAliasTrb)->R_E_C_N_O_}) == 0
						aadd(aRecsBCI,(cAliasTrb)->R_E_C_N_O_) 
					EndIf 
					(cAliasTrb)->(dbSkip())
				Enddo
				(cAliasTrb)->(DbCloseArea())

			Next
		
			For nI:=1 To Len(aRecsBCI)
	
				BCI->(DbGoto(aRecsBCI[nI]))
			
				If !PLSDELMOV(BCI->BCI_CODOPE + BCI->BCI_CODLDP + BCI->BCI_CODPEG,"1")
					lRet := .F.
					EXIT
				Else
					lRet := .T.
				EndIf
	
			Next	
		Else
			Return (.F.)
		EndIf
	Else
		If !MsgYesNo(STR0050,STR0048) // O processo será excluído. Deseja continuar? - Exclusão de Ressarcimento SUS
			Return (.F.)
		Else
			lRet := .T.
		EndIf
	EndIf

	B0W->(DbSetOrder(1))	//B0W_FILIAL+B0W_OPEMOV+B0W_CODIGO+B0W_SEQUEN
	If lRet		
		For nI:=1 To Len(aRecs)
	
			B0R->(DbGoto(aRecs[nI]))
			
			If B0W->(MsSeek(xFilial("B0W")+ B0R->(B0R_CODOPE + B0R_CODIGO)))
				While (!B0W->(Eof())) .And. B0W->B0W_CODIGO == B0R->B0R_CODIGO
					
					B0W->(RecLock("B0W",.F.))
						B0W->(DbDelete())
					B0W->(MsUnLock())	
				
				B0W->(DBSKIP()) 
				EndDo
			Endif
			
			B0R->(RecLock("B0R", .F.))
				B0R->(DbDelete())
			B0R->(MsUnLock())			
		Next
	
			B0O->(RecLock("B0O",.F.))
				B0O->(DbDelete())
			B0O->(MsUnLock())
		
		MsgInfo(STR0051,STR0048) // Processo excluído com sucesso-Exclusão de Ressarcimento SUS
		
	Else
		MsgInfo(STR0053,STR0048) //"Não foi possível excluir o ressarcimento. O processo já possu Guias concluídas" -Exclusão de Ressarcimento SUS 
	EndIf

Next

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa	 ³ f552AtB0O  ³ Autor ³ Michel Montoro    ³ Data ³ 17.12.12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para atualizar a tabela Andamentos Dos Processos    ³±±
±±³          ³ (B0O)				                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function f552AtB0O()
Local cSQL     	:= ""
Local aArea 	:= GetArea()
Local lRet     	:= .T.
Local nProOK	:= 0
Local nProTrans	:= 0
Local cStatus 	:= ""

cSQL := " SELECT B0R_IDANS, B0R_MESPRO, B0R_ANOPRO, B0R_DATPRO, B0R_HORPRO"
cSQL += " FROM "+ RetSQLName("B0R")
cSQL += " WHERE B0R_FILIAL = '"+ xFilial("B0R") +"'" 
cSQL += " AND B0R_STATUS IN ('1','2','4')" // 3 - Cancelado
cSQL += " AND D_E_L_E_T_ = ' ' "
cSQL += " GROUP BY B0R_IDANS, B0R_MESPRO, B0R_ANOPRO, B0R_DATPRO, B0R_HORPRO"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B0R001",.F.,.T.)

B0R001->( DbGoTop() )
If B0R001->( EOF() )
	lRet := .F.
Else
	While !B0R001->( EOF() )
		nProOK := nProTrans := 0

		cSQL := " SELECT B0R_FILIAL, B0R_IDANS, B0R_STATUS, B0R_CODIGO"
		cSQL += " FROM "+ RetSQLName("B0R")
		cSQL += " WHERE B0R_FILIAL = '"	+ xFilial("B0R") 	+"'" 
		cSQL += " AND B0R_STATUS IN ('1','2','4')" // 3 - Cancelado		
		cSQL += " AND B0R_IDANS = '"	+ B0R001->B0R_IDANS 	+"' "
		cSQL += " AND B0R_MESPRO = '"	+ B0R001->B0R_MESPRO 	+"' "
		cSQL += " AND B0R_ANOPRO = '"	+ B0R001->B0R_ANOPRO 	+"' "
		cSQL += " AND D_E_L_E_T_ = ' ' "
		
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TRBB0R",.F.,.T.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma os status da tabela B0R ...										³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		TRBB0R->( DbGoTop() )
		While !TRBB0R->( EOF() )
			nProOK 		+= IIf (TRBB0R->B0R_STATUS $ "1/2"	,1,0)
			nProTrans   += IIf (TRBB0R->B0R_STATUS $ "4"	,1,0)
			TRBB0R->( DbSkip() )
		EndDo		
		TRBB0R->(DbCloseArea())
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Descubro qual Status para tabela B0O ...								³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nProOK >= 1 .AND. nProTrans == 0
			cStatus := "1"  // Nenhum tranferido para o Processamento de Contas
		ElseIf nProOK == 0 .AND. nProTrans >= 1
			cStatus := "3"	// Totalmente tranferidos para o Processamento de Contas
		ElseIf nProOK >= 1 .AND. nProTrans >= 1
			cStatus := "2"	// Parcialmente transferido para o Processamento de Contas
		EndIf

		If !EMPTY(cStatus)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava ou Atualiza o resultado do Status na tabela B0O ...				³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			B0O->(dbSetOrder(2)) //B0O_FILIAL+B0O_ANOPRO+B0O_MESPRO+B0O_IDANS+B0O_STATUS
			If ! B0O->(MsSeek(xFilial("B0O")+B0R001->B0R_ANOPRO+B0R001->B0R_MESPRO+B0R001->B0R_IDANS))	
				B0O->(RecLock("B0O",.T.))
					B0O->B0O_FILIAL	:= xFilial("B0R")
					B0O->B0O_IDANS 	:= B0R001->B0R_IDANS
					B0O->B0O_MESPRO	:= B0R001->B0R_MESPRO
					B0O->B0O_ANOPRO	:= B0R001->B0R_ANOPRO
					B0O->B0O_DTXML	:= SToD(B0R001->B0R_DATPRO)
					B0O->B0O_HRXML	:= B0R001->B0R_HORPRO
					B0O->B0O_QTDPRO	:= nProOK + nProTrans
					B0O->B0O_STATUS	:= cStatus
				B0O->(MsUnLock())
			Else
				B0O->(RecLock("B0O",.F.))
					B0O->B0O_STATUS := cStatus
					B0O->B0O_QTDPRO := nProOK + nProTrans
				B0O->(MsUnLock())
	        EndIf
        EndIf
        
		B0R001->( DbSkip() )
	EndDo
EndIf

B0R001->(DbCloseArea())

RestArea(aArea)

Return(lRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Programa  ³ PL552SEL   ³ Autor ³ Michel Montoro      ³ Data ³ 14.12.12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Seleciona o Processo                        				  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL552SEL()

PRIVATE aCdCore2 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a seleção dos Processos ...                        			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If B0O->B0O_STATUS $ "3/"
	MsgInfo(STR0015 + ' ' + STR0014 + '. ' + STR0041) //"Processo" "Totalmente Transferido" "Permitido apenas visualizar Atendimentos! "
	lSoVisual := .T.
Else
	lSoVisual := .F.
EndIf


cAlias    	:= "B0R"
aCdCore2	:= {	{ 'BR_VERMELHO' ,STR0008 },;	//'Autorizada'"
					{ 'BR_AMARELO'  ,STR0009 },; 	//'Atendimento Incompleto'
					{ 'BR_VERDE'	,STR0010 }}  	//'Gerado Processamento de Contas'

aCore2   	:= {	{ cAlias+'_STATUS = "1"',aCdCore2[1,1] },;	//'Autorizada'
					{ cAlias+'_STATUS = "2"',aCdCore2[2,1] },;	//'Atendimento Incompleto'
					{ cAlias+'_STATUS = "4"',aCdCore2[3,1] } }	//'Gerado Processamento de Contas'

aRotina		:= MenuDef(2)
cCadastro	:= PLSRetTit(cAlias)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a chamada de acordo com filtro ...                        	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltro := "@B0R_FILIAL = '"+xFilial(cAlias)+"' AND B0R_STATUS <> '3' AND D_E_L_E_T_ = ' ' "
cFiltro += "AND B0R_IDANS  = '"+B0O->B0O_IDANS  + "' "
cFiltro += "AND B0R_MESPRO = '"+B0O->B0O_MESPRO + "' "
cFiltro += "AND B0R_ANOPRO = '"+B0O->B0O_ANOPRO + "' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta mbrowse padrao...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea(cAlias)
DbSetOrder(1)
SET FILTER TO &cFiltro

&(cAlias)->(mBrowse(ndLinIni,ndColIni,ndLinFin,ndColFin,cAlias,nil,nil,nil,nil,nil,aCore2,nil,nil,nil,nil,.F.,nil,nil,cFiltro))
&(cAlias)->(DbClearFilter())
SET KEY VK_F12 TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualizar Andamentos Dos Arquivos Importados (B0O)...	 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSoVisual // Se não for apenas Visual atualiza o B0O
	f552AtB0O()
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina Principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA552VIS ³ Autor ³ Michel Montoro     ³ Data ³ 17.12.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Modulo de visualização dos processos de importados do     ³±±
±±³          ³ Ressarcimento ao SUS                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSA552Vis(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PLSA552                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA552VIS(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis LOCAL...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nOpcA    := 0
LOCAL aPosObj  := {}
LOCAL aObjects := {}
LOCAL aSize    := {}
LOCAL aInfo    := {}
LOCAL bOK      := {|| nOpcA := 1,oDlg:End() }
LOCAL bCancel  := {|| oDlg:End() }
LOCAL bFilter
LOCAL aButtons := {{"S4WB005N"  ,{|| PL552LEG(aCdCore3,.T.) },OemtoAnsi(STR0005)}} //"Legenda"
LOCAL cChave   := B0R->(B0R_CODOPE+B0R_CODIGO)       //B0R->(B0R_FILIAL+B0R_CODOPE+B0R_CODIGO)
LOCAL aValRess := {}

STATIC oEnchoice
STATIC oBrwB0W
STATIC aTrbB0W := {}
STATIC aDadB0W := {}
STATIC aCabB0W := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oDlg
PRIVATE aVetTrab := {}
PRIVATE aCols    := {}
PRIVATE aHeader  := {}
PRIVATE aCdCore3 := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do folder de Procedimentos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCdCore3	:= {	{ 'BR_VERMELHO' ,"Procedimento Incompleto" },;	//"Procedimento Incompleto"
					{ 'BR_VERDE'	,"Procedimento Pronto" }}  		//"Procedimento Pronto"
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes iniciais														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BAU->(DbSetOrder(1))
If !BAU->(MsSeek(xFilial("BAU")+GetNewPar("MV_RDASUS","999999")))
	Help("",1,"PL550001")
	Return(.F.)
Endif

dbSelectArea("B0R")
B0R->(DbSetOrder(1))
RegToMemory("B0R",nOpc==K_Incluir)

Store Header "B0W" TO aCabB0W For (.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->B0R_USUARI := B0R->B0R_OPEUSR+B0R->B0R_CODEMP+B0R->B0R_MATRIC+B0R->B0R_TIPREG+B0R->B0R_DIGITO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta get do folder de procedimentos do Ressarcimento  				     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Store Header "B0W" TO aCabB0W For .T.
B0W->(DbSetOrder(1))
If !B0W->(MsSeek(xFilial("B0W")+B0R->B0R_CODOPE+B0R->B0R_CODIGO)) //B0W_FILIAL+B0W_OPEMOV+B0W_CODIGO+B0W_SEQUEN
	Store COLS Blank "B0W" TO aDadB0W FROM aCabB0W
Else	
	Store COLS "B0W" TO aDadB0W FROM aCabB0W VETTRAB aTrbB0W While B0W->(B0W_FILIAL+B0W_OPEMOV+B0W_CODIGO) == xFilial("B0R")+B0R->(B0R_CODOPE+B0R_CODIGO)
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia a construcao do Dialogo com usuario...                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 001, Iif(GetNewPar("MV_PLSMODA","1") == "0",020,Iif(nOpc == K_Incluir,000,020)), .T., .F.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
AAdd( aObjects, { 001, 000, .T., .T.,.T. } )

aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects )

aPosObj[1][2]+=15

aPosObj[2][1] 	-=20   //Linha Inicial da Enchoice
aPosObj[2][3]	+=35   //Linha Final da Enchoice

aPosObj[3][1]	+=35   //Linha Inicial do Folder
aPosObj[3][2]	-=02   //Coluna Inicial do Folder
aPosObj[3][3]	+=00   //Coluna Final do Folder
aPosObj[3][4]	-=25   //Linha Final do Folder


DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

oEnchoice := B0R->(MSMGet():New("B0R",nReg,nOpc,,,,,aPosObj[2],,,,,,oDlg,,,.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta folder dos procedimentos do processo                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder 		:= TFolder():New(aPosObj[3,1],aPosObj[3,2],{STR0021},{""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])  //"Eventos"###"Composição"
//oFolder:bChange := {|nFolder| oBrwB0W:oBrowse:oBrowse:Refresh(),P552SEQCRI()}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria GetDados...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrwB0W 		  := TPLSBrw():New(1,1,aPosObj[3,3]-3,aPosObj[3,4]-15,nil,oFolder:aDialogs[01],nil,nil,nil,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabB0W,aDadB0W ,.F.,"B0W",K_Visualizar,STR0023,nil,nil,nil,aTrbB0W,nil,nil,nil,nil,aValRess,nil,nil)
oBrwB0W:bGotFocus := {|| oBrwB0W:oBrowse:oBrowse:Refresh()}
oBrwB0W:aVetTrab  := aClone(aTrbB0W)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego o aDadRda da RDA referente ao SUS                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSDADRDA(M->B0R_OPERDA,M->B0R_CODRDA,"1",dDataBase,Subs(M->B0R_LOCATE,1,3),M->B0R_CODESP)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg,bOK,{||Eval(bCancel)},.F.,aButtons), oEnchoice:SetFocus() })

SET KEY VK_F5 TO
SET KEY VK_F6 TO
SET KEY VK_F7 TO
SET KEY VK_F8 TO
SET KEY VK_F9 TO
SET KEY VK_F10 TO
SET KEY VK_F11 TO
SET KEY VK_F12 TO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³P552SEQCRI³ Autor ³ Luzio Tavares         ³ Data ³ 13.06.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                                            
Function P552SEQCRI                          
LOCAL cRet := "001"

If ValType(oBrwB0W) == "O"
   cRet := oBrwB0W:FieldGet("B0W_SEQUEN")
EndIf	

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA552TRF ³ Autor ³ Michel Montoro    ³ Data ³ 17.12.12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para gerar o contas medicas a partir do processo    ³±±
±±³          ³ de ressarcimento ao SUS                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA552TRF(cAliasAnt,nReg,nOpc,lLote)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cCodInt 	:= PLSINTPAD()
LOCAL cAlias   	:= "BD5"  //Vai depender do tipo de guia contido no campo B0R_TIPGUI
LOCAL cOriMov	:= ""
LOCAL aRet     	:= {.T.,{}}
LOCAL aFilesGrv	:= {}
LOCAL cMacro	:= ""   
LOCAL cCodEmp 	:= B0R->B0R_CODEMP
LOCAL cMatric 	:= B0R->B0R_MATRIC
LOCAL cTipReg 	:= B0R->B0R_TIPREG
LOCAL cDigito 	:= B0R->B0R_DIGITO
LOCAL dDatPro 	:= B0R->B0R_DATPRO
LOCAL cMvTABSUS :=  GETMV("MV_TABSSUS")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variaveis da rotina...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nFor		:= 0
LOCAL nAux		:= 0
LOCAL nPos		:= 0
LOCAL cAliasAux	:= ""
LOCAL cNumGuia	:= ""
LOCAL cCODOPE	:= ""
LOCAL cCODLDP	:= ""
LOCAL cCODPEG	:= ""
LOCAL cTIPGUI	:= ""
LOCAL cMESPAG	:= ""
LOCAL cANOPAG	:= ""
LOCAL cFase		:= "3"
LOCAL cTipGuia 	:= Space(0)
LOCAL cAliasPri	:= Space(0)
LOCAL aStruARQ  := {}
LOCAL aRetCal   := PLSXVLDCAL(dDatPro,cCodInt,.F.)    // Valida o calendario de pagamento da operadora
LOCAL cAnoBase  := aRetCal[4]
LOCAL cMesBase  := aRetCal[5]
LOCAL nStackSX8 := GetSx8Len()
Local cMVCodLDP	:= GetNewPar("MV_CDLCSUS","5000")
LOCAL aArrayBD6	:= {}	// recebe o n total de registros
LOCAL aArrayBEA	:= {}
LOCAL nProc     := 1 	// incrementado por unidade de registro
LOCAL Npercent  := 0
LOCAL nQ 		:= 0
LOCAL cQuery 	:= Space(0)
LOCAL cOpeRDA  	:= cCodInt
LOCAL cCodRDA	:= B0R->B0R_CODRDA
LOCAL cFunGRV
LOCAL cTipGRV
LOCAL cNewPEG
LOCAL aRetFun 
LOCAL aChave 	:= {}
LOCAL aColsB0W 	:= {}
LOCAL aRetBene	:= PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
LOCAL cNomUsr	:= IIf( LEN(aRetBene) >= 14, aRetBene[14], "" )
LOCAL cBTipo	:= ""
LOCAL cBLocal	:= ""
LOCAL cBEnder	:= ""     
LOCAL aDadUsr   := {}
LOCAL cCrit		:= ""
LOCAL cNumCRM	:= ""
LOCAL cCodSig	:= ""
LOCAL cEstExe	:= ""
LOCAL cNomExe	:= ""
LOCAL cCodExe	:= ""

STATIC aVTrbB0W := {}
STATIC aHeadB0W := {}

DEFAULT lLote 	:= .F.

If !lLote .And. lSoVisual
	MsgInfo(STR0041)//"Permitido apenas visualizar Atendimentos! "
	Return
EndIf

If !lLote .And. !MsgYesNo(STR0025) //"Deseja transferir para o Processamento de Contas o registro selecionado ?"
	Return
EndIf

/*Validacoes iniciais*/

//Verifica se na data de atendimento possui calendario de pagamento
If !(aRetCal[1])
	cCrit := "Não existe calendario de pagamento ou parâmetros mensais para a data do atendimento"
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet

EndIf

//Verifica se o atendimento esta completo
If B0R->B0R_STATUS $ "2"
	cCrit := STR0009 //"Atendimento Incompleto" 
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet
	
EndIf

//Verifica se o atendimento nao esta cancelado
If B0R->B0R_STATUS $ "3"
	cCrit:= MsgInfo(STR0017) //"Atendimento Cancelado!"
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet
EndIf
//Verifica se o atendimento ja foi transferido
If !Empty(B0R->B0R_CODPEG) .OR. B0R->B0R_STATUS $ "4/"
	cCrit := STR0036 + STR0018 //"Atendimento" "ja incluido no Processamento de Contas! "
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet
EndIf

// Somente se existir codigo correlato a tabela TUNEP...
If B0W->( FieldPos("B0W_DESPRO") ) > 0
	cQuery := "SELECT B0W.B0W_CODPRO,B0W.B0W_CODPAD,B0W.B0W_QTDPRO,B0W.B0W_VLRAPR,B0W.B0W_SEQUEN,R_E_C_N_O_ AS B0WRECNO, B0W.B0W_DESPRO, B0W.B0W_TUNEP "
Else
	cQuery := "SELECT B0W.B0W_CODPRO,B0W.B0W_CODPAD,B0W.B0W_QTDPRO,B0W.B0W_VLRAPR,B0W.B0W_SEQUEN,R_E_C_N_O_ AS B0WRECNO, B0W.B0W_TUNEP "
EndIf
cQuery += "FROM "+RetSqlName("B0W")+" B0W "
cQuery += "WHERE B0W.B0W_FILIAL = '" + xFilial("B0W") + "' "
cQuery += "AND B0W.B0W_CODIGO = '" + B0R->B0R_CODIGO + "' "
cQuery += "AND B0W.B0W_CODPRO <> '"+ Space(TamSX3("B0W_CODPRO")[1]) +"' "
//cQuery += "AND B0W.B0W_VLRPAG > 0 "
cQuery += "AND B0W.B0W_VLRAPR > 0 "
cQuery += "AND B0W.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY B0W_CODIGO, B0W_SEQUEN "

cQuery := ChangeQuery(cQuery)
If Select("TRBB0W") > 0
	TRBB0W->( dbCloseArea() )
EndIF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBB0W",.F.,.T.)

// Trata se nao existir registros...
dbSelectArea("TRBB0W")
COUNT to nTotal // Conta o total de registro na tabela temporaria

TRBB0W->(DbGoTop())

If TRBB0W->(Eof())

	TRBB0W->( DbCloseArea() )
	cCrit := STR0020 //"Nenhum codigo da tabela padrao correspondente ao codigo da TUNEP foi encontrado para gerar a guia! "
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet

EndIf               

cAlias		:= "BD5"
cTipGuia	:= "02"
cOriMov		:= "1"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o PEG eletronico do mes para o credenciado...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BCL->(DbSetOrder(1))
If BCL->( MsSeek( xFilial("BCL") + cCodInt + cTipGuia ) )
	cFase := BCL->BCL_FASE
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe o PEG eletronico do mes para o credenciado...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BCI->(DbSetOrder(4))   //BCI_FILIAL+BCI_OPERDA+BCI_CODRDA+BCI_ANO+BCI_MES+BCI_TIPO+BCI_FASE+BCI_SITUAC+BCI_TIPGUI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego o aDadRda da RDA referente ao SUS                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetFun := PLSDADRDA(B0R->B0R_OPERDA,B0R->B0R_CODRDA,"1",dDataBase,Subs(B0R->B0R_LOCATE,1,3),B0R->B0R_CODESP)
If !aRetFun[1]   
	cCrit := aRetFun[2][1]
	
	If Valtype(cCrit) =="A" 
		cCrit := aRetFun[2,1,2]
	Endif
	
	if !lLote
		ApMsgStop(cCrit,"Processo não pode ser realizado.")
	else
		AddCrit(B0R->B0R_CODIGO,cCrit,Str(B0R->B0R_VALOR),aRet)
	endif
	
	Return aRet
  	
EndIf
 
If ! BCI->(MsSeek(xFilial("BCI")+cOpeRDA+cCodRDA+cAnoBase+cMesBase+"2"+cFase+"1"+cTipGuia+cMVCodLDP)) .AND. ! BCI->(MsSeek(xFilial("BCI")+cOpeRDA+cCodRDA+cAnoBase+cMesBase+"2"+"1"+"1"+cTipGuia+cMVCodLDP)) //Busca se há PEG em digitação, só cria novo se não achar
	
	cNewPEG := PLSA175Cod(cOpeRDA,cCodInt)
	
	BCI->(RecLock("BCI",.T.))
		BCI->BCI_FILIAL := xFilial("BCI")
		BCI->BCI_CODOPE := cOpeRDA
		BCI->BCI_PROTOC := CriaVar("BCI_PROTOC")
		BCI->BCI_CODLDP := cMVCodLDP
		BCI->BCI_CODPEG := cNewPEG
		BCI->BCI_OPERDA := cOpeRDA
		BCI->BCI_CODRDA := cCodRDA
		BCI->BCI_CGCRDA := Posicione("BAU",1,xFilial("BAU")+cCodRDA,"BAU_CPFCGC")
		BCI->BCI_NOMRDA := BAU->(Posicione("BAU",1,xFilial("BAU")+cCodRDA,"BAU_NOME"))
		BCI->BCI_TIPPRE := BAU->(Posicione("BAU",1,xFilial("BAU")+cCodRDA,"BAU_TIPPRE"))
		BCI->BCI_TIPSER := GetNewPar("MV_PLSTPSP","01")
		BCI->BCI_TIPGUI := cTipGuia	
		BCI->BCI_DTDIGI := Date()
	    BCI->BCI_ARQUIV := B0R->B0R_ARQIMP
		// Procura pelas funcoes basicas de gravacao e mudanca de fase dependendo do tipo de guia
		BCL->(DbSetOrder(1))
		BCL->(MsSeek(xFilial("BCL")+cCodInt+BCI->BCI_TIPGUI))
		BCI->BCI_VLRGUI := 0 //TODO
		BCI->BCI_DATREC := dDataBase
		BCI->BCI_QTDDIG := 1
		BCI->BCI_CODCOR := BCL->BCL_CODCOR
		BCI->BCI_FASE   := "1"
		BCI->BCI_SITUAC := "1"
		BCI->BCI_STATUS := "1"
		BCI->BCI_MES    := cMesBase
		BCI->BCI_ANO    := cAnoBase
		BCI->BCI_TIPO   := "2"
	BCI->(MsUnLock())
	
	While GetSx8Len() > nStackSX8
		BCI->( ConfirmSX8() )
	EndDo
Else
	BCL->(DbSetOrder(1))
	BCL->(MsSeek(xFilial("BCL")+cCodInt+BCI->BCI_TIPGUI))
Endif

cFunGRV   := BCL->BCL_FUNGRV
cTipGRV   := BCL->BCL_TIPGRV

//Localiza o codigo do profissional caso o Prestador faça parte da rede de atendimento da Operadora
if B0R->(FieldPos('B0R_CDCNES')) > 0 .And. !empty(B0R->B0R_CDCNES)
	//Verifica se existe um local de atendimento para o CNES informado
	BB8->(dbOrderNickName("CNES"))//BB8_FILIAL+BB8_CNES
	if BB8->(MsSeek(xFilial("BB8") + B0R->B0R_CDCNES))
		BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO
		if BAU->(MsSeek(xFilial("BAU") + BB8->BB8_CODIGO))
			BB0->(DbSetOrder(1))//BB0_FILIAL+BB0_CODIGO
			if BB0->(MsSeek(xFilial("BB0") + BAU->BAU_CODBB0))
				cNumCRM := BB0->BB0_NUMCR 
				cCodSig := BB0->BB0_CODSIG
				cEstExe := BB0->BB0_ESTADO
				cNomExe := BB0->BB0_NOME	
				cCodExe := BB0->BB0_CODIGO
			endif
		endif
	endif
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do processo de gravacao das guias...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFilesGrv := PLSA500FIL(BCL->BCL_CODOPE,BCL->BCL_TIPGUI,"2")

//Dados fixos para todos os arquivos a serem procesados do contas medicas
cCODOPE 	:= BCI->BCI_CODOPE
cCODLDP 	:= BCI->BCI_CODLDP
cCODPEG 	:= BCI->BCI_CODPEG
cTIPGUI 	:= BCI->BCI_TIPGUI
cMesBase	:= BCI->BCI_MES
cAnoBase	:= BCI->BCI_ANO

aDadUsr:= PLSDADUSR(cCodint+B0R->B0R_CODEMP+B0R->B0R_MATRIC+B0R->B0R_TIPREG+B0R->B0R_DIGITO,"1",,dDataBase,,,,,,.F.)

cBTipo			:= BCI->BCI_TIPO
cBLocal		:= Posicione('BB8',1,xFilial('BAU')+cCodRDA,'BB8_LOCAL') 
cBEnder		:= Posicione('BB8',1,xFilial('BAU')+cCodRDA,'BB8_END')


If aDadUsr[1]
	If 	!Empty(aDadUsr[3])
		cCodMatAnt:= aDadUsr[3]
	Else
		cCodMatAnt:= IIF(B0R->( FieldPos("B0R_CODBEN") ) > 0, B0R->B0R_CODBEN, GetNewPar('MV_MATGSUS',""))
	Endif
Else
	cCodMatAnt:= GetNewPar('MV_MATGSUS',"")
Endif	


aArrayBEA := 	{;
				{"BEA_OPEMOV", cCodInt			},;
				{"BEA_OPEUSR", B0R->B0R_OPEUSR	},;
				{"BEA_CODEMP", B0R->B0R_CODEMP	},;  
				{"BEA_MATRIC", B0R->B0R_MATRIC	},;  
				{"BEA_TIPREG", B0R->B0R_TIPREG	},;
				{"BEA_DIGITO", B0R->B0R_DIGITO	},;
				{"BEA_CPFUSR", B0R->B0R_CPFUSR	},;
				{"BEA_IDUSR" , B0R->B0R_IDUSR	},;
				{"BEA_CONEMP", B0R->B0R_CONEMP	},;
				{"BEA_VERCON", B0R->B0R_VERCON	},;
				{"BEA_SUBCON", B0R->B0R_SUBCON	},;
				{"BEA_VERSUB", B0R->B0R_VERSUB	},;
				{"BEA_TIPO"  , cBTipo			},;
				{"BEA_CODLOC", B0R->B0R_CODLOC	},;
				{"BEA_LOCAL" , cBLocal			},;
				{"BEA_DESLOC", B0R->B0R_DESLOC	},;
				{"BEA_ENDLOC", cBEnder			},;
				{"BEA_CODESP", B0R->B0R_CODESP	},;
				{"BEA_DESESP", B0R->B0R_DESESP	},;
				{"BD5_BLOCPA", Space(0)			},; // Bloqueia a cobranca da co-participacao     Na BD5 o campo é BLOPAG
				{"BD5_DESBPF", Space(0)			},; // Descricao do codigo usado no bloqueio da co-participacao    Na BD5 o campo é DESBPG
				{"BD5_MOTBPF", Space(0)			},; // INFORME O CODIGO DO BLOQUEIO DA COPARTICIPACAO DE ACORDO COM A TABELA DE BLOQUEIO  Na BD5 é MOTBPG
				{"BEA_DATNAS", B0R->B0R_DATNAS	},; // Data de Nascimento do Beneficiario
				{"BEA_DATPRO", B0R->B0R_DATEVE	},;
				{"BEA_HORPRO", B0R->B0R_HORPRO	},;
				{"BEA_DTDIGI", date()			},;
				{"BEA_TIPPRE", B0R->B0R_TIPPRE	},;
				{"BEA_TIPADM", B0R->B0R_TIPADM	},;
				{"BEA_MESPAG", cMesBase			},;
				{"BEA_ANOPAG", cAnoBase			},;
				{"BEA_OPERDA", B0R->B0R_OPERDA	},;
				{"BEA_CODRDA", B0R->B0R_CODRDA	},;
				{"BEA_NOMRDA", B0R->B0R_NOMRDA	},;
				{"BEA_SIGLA" , B0R->B0R_SIGLA	},;
				{"BD5_BLOPAG", "0"				},;
				{"BD5_LOCATE", B0R->B0R_LOCATE	},;
				{"BD5_REGATE", "1"				},;
				{"BD5_FASE"  , "3"				},;
				{"BD5_SITUAC", "1"				},;
				{"BEA_LIBERA", "1"				},;
				{"BEA_PAGATO", "0"				},; //Determina o Pagamento no ATO como 0 pois esse conceito não será aplicato a Guia de Ressarcimento SUS.
				{"BD5_TIPINT", "0"				},;
				{"BEA_ORIMOV", cOriMov			},;
				{"BEA_TIPPAC", getNewPar("MV_PLSTPAA","9")},;
				{"BEA_MATVID", B0R->B0R_MATVID	},;
				{"BEA_NUMIMP", B0R->B0R_AIHAPA  },;
				{"BEA_MATUSA", "1"				},;
				{"BEA_NOMUSR", IIF(EMPTY(cNomUsr),B0R->B0R_NOMUSR,cNomUsr) },;
				{"BEA_MATANT", cCodMatAnt		} ,;
				{"BEA_ESTEXE", cEstExe			},;
				{"BEA_REGEXE", cNumCRM			},;
				{"BEA_SIGEXE", cCodSig			},;
				{"BEA_NOMEXE", cNomExe			},;
				{"BEA_CDPFRE", cCodExe			}}

While !TRBB0W->(Eof())
	aAdd ( aArrayBD6  , ;
	{	{"CODINT"	, cCodInt				},;	// 01 No BD5 é CODOPE
		{"CODEMP"	, B0R->B0R_CODEMP		},;	// 02
		{"MATRIC"	, B0R->B0R_MATRIC		},;	// 03
		{"TIPREG"	, B0R->B0R_TIPREG		},;	// 04
		{"DIGITO"	, B0R->B0R_DIGITO		},;	// 05
		{"CODPRO"	, TRBB0W->B0W_CODPRO	},;	// 06
		{"CODPAD"	, TRBB0W->B0W_CODPAD	},;	// 07 Codigo do tipo de tabela de saude
		{"CODESP"	, B0R->B0R_CODESP		},;	// 08
		{"QTDPRO"	, TRBB0W->B0W_QTDPRO	},;	// 09 Nao aparece na BD5
		{"QTDAPR"	, TRBB0W->B0W_QTDPRO	},;	// 10 Nao aparece na bd5
		{"BLOCPA"	, Space(0)				},;	// 11 Bloqueia a cobranca da co-participacao     Na BD5 o campo é BLOPAG
		{"DESBPF"	, Space(0)				},;	// 12 Descricao do codigo usado no bloqueio da co-participacao    Na BD5 o campo é DESBPG
		{"MOTBPF"	, Space(0)				},;	// 13 INFORME O CODIGO DO BLOQUEIO DA COPARTICIPACAO DE ACORDO COM A TABELA DE BLOQUEIO  Na BD5 é MOTBPG
		{"DATNAS"	, B0R->B0R_DATNAS		},;	// 14 Data de Nascimento do Beneficiario //	{'DATNAS', DtoS(TRBB0W->BA1_DATNAS)},; // Data de Nascimento do Beneficiario
		{"VLRPRO"	, TRBB0W->B0W_VLRAPR	},;	// 15
		{"VLRPAG"	, TRBB0W->B0W_VLRAPR	},;	// 16
		{"OPEUSR"	, B0R->B0R_OPEUSR		},;	// 17
		{"DATPRO"	, B0R->B0R_DATEVE		},;	// 18
		{"HORPRO"	, B0R->B0R_HORPRO		},;	// 19
		{"TIPPRE"	, B0R->B0R_TIPPRE		},;	// 20
		{"MESPAG"	, cMesBase				},;	// 21
		{"ANOPAG"	, cAnoBase				},;	// 22
		{"OPERDA"	, B0R->B0R_OPERDA		},;	// 23
		{"CODRDA"	, B0R->B0R_CODRDA		},;	// 24
		{"NOMRDA"	, B0R->B0R_NOMRDA		},;	// 25
		{"SIGLA" 	, B0R->B0R_SIGLA		},;	// 26
		{"BLOPAG"	, "0"					},;	// 27
		{"LOCATE"	, B0R->B0R_LOCATE		},;	// 28
		{"REGATE"	, "1"					},;	// 29
		{"CODPRC"	, TRBB0W->B0W_CODPRO	},;	// 30 Codigo do procedimento para lancamento no contas medicas
		{"FASE"  	, "3"					},;	// 31
		{"SITUAC"	, "1"					},;	// 32
		{"LIBERA"	, "1"					},;	// 33
		{"PAGATO"	, "1"					},;	// 34
		{"TIPINT"	, "0"					},;	// 35
		{"ORIMOV"	, cOriMov				},;	// 36
		{"MATUSA"	, "1"					},;	// 37
		{"CDPADP"	, TRBB0W->B0W_CODPAD	},;	// 38 Codigo do tipo de tabela de saude
		{"SEQUEN"	, TRBB0W->B0W_SEQUEN	},;	// 39
		{"B0WRECNO"	, TRBB0W->B0WRECNO		},;	// 40
		{"NUMAUT"	, ""					},;	// 41
		{"MATVID"	, B0R->B0R_MATVID		},;	// 42
		{"DESPRO"	, Posicione('BR8',1,xFilial('BR8')+TRBB0W->B0W_CODPAD+TRBB0W->B0W_CODPRO,'BR8_DESCRI')},;	// 43
		{"NOMUSR"	, IIF(EMPTY(cNomUsr),B0R->B0R_NOMUSR,cNomUsr)},; // 44		
		{"TIPO"  	, cBTipo		   		},;	// 45
		{"CODLOC"	, B0R->B0R_CODLOC  		},;	// 46
		{"LOCAL" 	, cBLocal		   		},;	// 47
		{"DESLOC"	, B0R->B0R_DESLOC  		},;	// 48
		{"ENDLOC"	, cBEnder		   		},; //49
		{"SLVPAD"	, cMvTABSUS	},; //50
		{"SLVPRO"	, TRBB0W->B0W_TUNEP		},; //51
		{"SLVDES"	, IIF(B0W->( FieldPos("B0W_DESPRO") ) > 0,TRBB0W->B0W_DESPRO ,"")}}) //52
		
	TRBB0W->(DbSkip())
EndDo



// Monta get do folder de procedimentos do Ressarcimento
Store Header "BE2" TO aHeadB0W For .T.

aColsB0W := PLA552BD6(aArrayBD6,aHeadB0W)
 
aStruARQ := PLSA090Grv(	aColsB0W,				aHeadB0W,				aArrayBEA,				nOpc,;
						/*aVetTrab*/NIL,   		/*aChaveGen?*/{},		/*_USUARI?*/"",			B0R->B0R_DATEVE,;
						B0R->B0R_HORPRO,		/*_MATUSA*/"1",			cAnoBase,				cMesBase,;
	     				cTIPGUI,				/*lIntern*/NIL,			/*aColsCrit*/NIL,		/*aHeaderCrit*/NIL,;
	     				/*aVetTrabCrit*/NIL,	/*lAutori*/NIL,			/*cTipo*/NIL,			IIf((nOpc == K_Incluir .Or. nOpc == K_Copiar),cCODLDP,BCI->BCI_TIPGUI),;
	     				Nil,					/*cFiltro*/NIL,			NIL,					NIL,;
	     				NIL,					/*lNMudFase*/.T.,		NIL,					NIL,;
	     				NIL,					NIL,					NIL,					/*lGerSenha*/.F.,;
	     				/*lWeb*/.F.,			/*aDadB43*/NIL,			/*aCabB43*/NIL,			/*aTrbB43*/NIL,;
	     				,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,/*aMatCom*/NIL,,;
	     				,,,,,,,,,,,,,,,,,,,,,,.T.,aArrayBD6)


If aStruARQ[1]
	RecLock( "B0R", .F. )
		B0R->B0R_STATUS := "4"  //Status do Processo igual a Tranferido
		B0R->B0R_CODOPE := aStruARQ[02]
		B0R->B0R_CODLDP := cCODLDP
		B0R->B0R_CODPEG := cCODPEG
		B0R->B0R_NUMERO := BD5->BD5_NUMERO //aStruARQ[05] 
		B0R->B0R_TIPGUI := aStruARQ[08]
		B0R->B0R_MESPAG := aStruARQ[04]
		B0R->B0R_ANOPAG := aStruARQ[03]
	B0R->( MsUnLock() )

	For nFor := 1 TO LEN(aArrayBD6)
		nPos := aScan(aArrayBD6[1], {|x| alltrim(x[1]) = "B0WRECNO"})
		If nPos > 0
			B0W->(dbGoTo( aArrayBD6[nFor][nPos][2] )) 	// Posiciono no registro marcado
			RecLock( "B0W", .F. )
				B0W->B0W_STATUS := "4"  //Status do Processo igual a Tranferido
				B0W->B0W_CODLDP := cCODLDP
				B0W->B0W_CODPEG := cCODPEG
				B0W->B0W_NUMERO := BD5->BD5_NUMERO //aStruARQ[05]
			B0W->( MsUnLock() )
		EndIf
	Next nFor

    If !lLote
		MsgInfo(STR0019) // "Gravacao da Guia no Processamento de Contas concluida com sucesso !!!"
	EndIf
Endif

TrbB0W->( DbCloseArea() )

Return(aRet)

/*/{Protheus.doc} AddCrit
Adiciona criticas para serem exibidas ao final do processamento de transferencia por lote
@author victor.silva
@since 23/03/2017
/*/
static function AddCrit(cCodAte,cCrit,cVal,aRet)

aRet[1] := .F.
aAdd(aRet[2],{cCodAte,cCrit,cVal})

return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA552TLO ³ Autor ³ Michel Montoro    ³ Data ³ 21.12.12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para gerar o contas medicas em Lote através de para ³±±
±±³          ³ metros a partir do processo de ressarcimento ao SUS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA552TLO(cAlias,nReg,nOpc)
LOCAL lRet		:= .T.
LOCAL aFilAdic	:= {}
LOCAL cFiltroB0R:= ""
LOCAL aCabB0R 	:= {}
LOCAL aDadB0R 	:= {}
LOCAL nX		:= 0
LOCAL cCpoBrw	:= "B0R_OFICIO,B0R_NUMPRO,B0R_CODIGO,B0R_CODRDA,B0R_NOMRDA,B0R_USUARI,B0R_MESPRO,B0R_ANOPRO,B0R_DATPRO,B0R_DATEVE,B0R_VALOR"
Private oProcess

If lSoVisual
	MsgInfo(STR0041)//"Permitido apenas visualizar Atendimentos! "
	Return({.F.})
EndIf

aFilAdic := PLSA552Fil()

If !aFilAdic[1]
   	Return
Endif   

cFiltroB0R := "SELECT B0R_IDANS, B0R_OFICIO, B0R_NUMPRO, B0R_CODIGO, B0R_STATUS, B0R_CODRDA, B0R_NOMRDA, B0R_MESPRO, B0R_USUARI, "
cFiltroB0R += "B0R_ANOPRO, B0R_DATPRO, B0R_DATEVE, B0R_VALOR, B0R_AIHAPA, R_E_C_N_O_ AS B0RRECNO "
cFiltroB0R += "FROM "+ RetSQLName("B0R") +" "
cFiltroB0R += "WHERE B0R_FILIAL = '"+ xFilial("B0R") +"' AND B0R_CODOPE = '"+ PLSINTPAD() +"' AND D_E_L_E_T_ = ' ' "
cFiltroB0R += "AND B0R_IDANS  = '"+ AllTrim(B0R->B0R_IDANS)  +"' "
cFiltroB0R += "AND B0R_MESPRO = '"+ AllTrim(B0R->B0R_MESPRO) +"' "
cFiltroB0R += "AND B0R_ANOPRO = '"+ AllTrim(B0R->B0R_ANOPRO) +"' "
cFiltroB0R += "AND B0R_DATPRO = '"+ DToS(B0R->B0R_DATPRO)    +"' "
cFiltroB0R += "AND B0R_HORPRO = '"+ AllTrim(B0R->B0R_HORPRO) +"' "
cFiltroB0R += "AND B0R_STATUS  IN ('1') "
If !Empty(aFilAdic[2])
	cFiltroB0R += AllTrim(aFilAdic[2])
EndIf

Store Header "B0R" TO aCabB0R For ( AllTrim(SX3->X3_CAMPO) $ cCpoBrw )

cFiltroB0R := ChangeQuery(cFiltroB0R)
If Select("TrbB0R") > 0
	TrbB0R->( dbCloseArea() )
EndIF
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cFiltroB0R),"TrbB0R",.F.,.T.)
TrbB0R->(DbGoTop())

While ! TrbB0R->(Eof())
	Aadd(aDadB0R,Array(Len(aCabB0R)+2))
		
	For nX := 1 To (Len(aCabB0R)+ 1)
		If nX == (Len(aCabB0R)+ 1)
			aDadB0R[Len(aDadB0R)][nX] := TrbB0R->B0RRECNO
		Else				
			If ( aCabB0R[nX,10] <>  "V" )
				If aCabB0R[nX,8] <> "D"
					aDadB0R[Len(aDadB0R)][nX] := TrbB0R->(FieldGet(FieldPos(aCabB0R[nX,2])))
				Else
					aDadB0R[Len(aDadB0R)][nX] := SToD(TrbB0R->(FieldGet(FieldPos(aCabB0R[nX,2]))))
				EndIf
			Else
				aDadB0R[Len(aDadB0R)][nX] := CriaVar(aCabB0R[nX,2],.T.)
			EndIf
		EndIf
	Next nX
	aDadB0R[Len(aDadB0R)][Len(aCabB0R)+2] := .F.
		
	TrbB0R->(DbSkip())
EndDo

TrbB0R->(DbCloseArea())

If Len(aDadB0R) > 0
	// MarkBrowse do B0R
	oProcess := MsNewProcess():New( { || lRet := MarkBB0R(aDadB0R,aCabB0R,035,015,050,015,490,155) } , "Tranferindo" , "Aguarde..." , .F. )
	oProcess:Activate()
Else
    MsgAlert(STR0035) //"Não existem Atendimentos dentro dos parâmetros informados."
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MarkBB0R	  ³ Autor ³ Michel Montoro    ³ Data ³ 02.01.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria um markbrowse dinamicamente                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MarkBB0R(aLinha,aCabecalho,nCheLi,nCheCo,nPosLI,nPosCI,nPosCF,nPosLF)

LOCAL nFor		:= 0
LOCAL nI		:= 0
LOCAL nOpca    	:= 0
LOCAL nProtoc	:= 0
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL aRet 		:= {.T.}
Local aCritic	:= {}
LOCAL lCheck 	:= .T. 
LOCAL bBlock
LOCAL oCheck

LOCAL oDlg

// variaveis lgpd 
local objCENFUNLGP  := CENFUNLGP():New() 
local aCamposCen  	:= {} 
local aBls  		:= {} 
local nCen 			:= 1

PRIVATE oLista

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0037 FROM 030,020 TO 060 ,150 OF GetWndDefault() //"Atendimentos" //050,100 OF GetWndDefault()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Checkbox para marcar e desmarcar todos														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ nCheLi,nCheCo CHECKBOX oCheck VAR lCheck PROMPT STR0038 OF oDlg SIZE 100,8 //"Marca e Desmarca todos"
	oCheck:bChange := {|| MsAguarde( {|| MarcaLinha('',aLinha,lCheck),oLista:Refresh() } ) }   

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o TcBrowse																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLista := TcBrowse():New( nPosLI,nPosCI,nPosCF,nPosLF,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona o BitMap de marcado e desmarcado													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	add COLUMN To oLista BitMap Data { || LoadBitMap( GetResources(), Iif(!aLinha[oLista:nAt,Len(aLinha[oLista:nAt])] ,EVal({|| lCheck := .F.,"LBNO"}),"LBOK" ) )} Title "" WIDTH 015 NOHILITE

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o cabecalho																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 to Len(aCabecalho)
	     bBlock := "{ || aLinha[oLista:nAt, "+Str(nFor,4)+"] }"
	     bBlock := &bBlock
	     oLista:AddColumn(TcColumn():New(aCabecalho[nFor,1],bBlock,aCabecalho[nFor,3],Nil,Nil,Nil,IiF(Len(aCabecalho[nFor,1]) > aCabecalho[nFor,4],Len(aCabecalho[nFor,1])*3.6,aCabecalho[nFor,4]*3.6),.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega os dados																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oLista:SetArray(aLinha)   

	if objCENFUNLGP:isLGPDAt()
		aadd(aCamposCen,.f.)
		for nCen := 1 to len(aCabecalho)
			aadd(aCamposCen,aCabecalho[nCen,2])
		next
		aBls := objCENFUNLGP:getTcBrw(aCamposCen)

		oLista:aObfuscatedCols := aBls
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Duploclick na linha																			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    oLista:BLDBLCLICK := { || MarcaLinha(oLista:nAt,aLinha,lCheck) , oLista:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa a dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER

If nOpca = K_OK
	
	For nFor := 1 to Len(aLinha)	
		If aLinha[nFor,(Len(aCabecalho)+2)]	//LINHA MARCADA
			nProtoc += 1
		EndIf
	Next nFor

	If nProtoc > 0	//Internacao selecionada	
		If MsgYesNo(AllTrim(Str(nProtoc)) + "  " + STR0039) //"Atendimento(s) será(ão) transferido(s) para Processamento de Contas. Confirma?"
			
			oProcess:SetRegua1( Len(aLinha) ) //Alimenta a primeira barra de progresso
			
			For nFor := 1 to Len(aLinha)
				
				oProcess:IncRegua1( "Processando Lote: [" + cValToChar(nFor) + "] / [" + cValToChar(Len(aLinha)) + "] ")	    		  
				
				If aLinha[nFor,(Len(aCabecalho)+2)]	// Linha marcada

					B0R->(dbGoTo(aLinha[nFor,LEN(aLinha[nFor])-1])) 	// Posiciono no registro marcado

					// Grava o Registro...
					aRet := PLSA552TRF("B0R",aLinha[nFor,LEN(aLinha[nFor])-1],3,.T.)

					If !aRet[1] // Se retornar Falso gravo as críticas para apresentar no final
						For nI := 1 To LEN(aRet[2])
							aAdd(aCritic,{AllTrim(aRet[02,nI,01]),AllTrim(aRet[02,nI,02]),AllTrim(aRet[02,nI,03])})
						Next nI
					EndIf
					
				EndIf
			
			Next nFor

			// Se houveram críticas exibe o log
			if Len(aCritic) > 0
				if MsgYesNo("O Processamento foi concluido porem houveram criticas, deseja visualiza-las?")
					PLSCRIGEN(aCritic,{ {"ATENDIMENTO","@C",25},{"CRITICA","@C",60},{"VALOR","@C",20} },"RESUMO DE CRÍTICAS")
				endif
			else
				MsgInfo(STR0019) // "Gravacao da Guia no Processamento de Contas concluida com sucesso !!!"
			endif
				
		Else
			RollBackSX8()		
		EndIf		
	Else
		MsgAlert(STR0040) //"Nenhum Atendimento foi selecionado."
	EndIf
EndIf

Return (aRet[1])

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA552Fil ³ Autor ³ Michel Montoro    ³ Data ³ 21.12.2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cria filtro para os Atendimentos que poderão serem		  ³±± 
±±³          ³ transferidos												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSA552Fil()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
LOCAL oDlg
LOCAL cFiltro  	:= ""
LOCAL nOpca    	:= 0
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL nInd
LOCAL nFor
LOCAL oChkCab
LOCAL lChk01   	:= .F.
LOCAL lChk02   	:= .F.
LOCAL lChk03   	:= .F.
LOCAL lChk04    := .F.
LOCAL lChk05    := .F.
LOCAL lChk06    := .F.
LOCAL nColIni  	:= 020
LOCAL nLinIni  	:= 025                     
LOCAL cTipoPre		:= Space(50)
LOCAL cMesDe		:= Space(02)
LOCAL cMesAt		:= Space(02)
LOCAL cAnoDe		:= Space(04)
LOCAL cAnoAt		:= Space(04)
LOCAL cProtoDe		:= Space(08)
LOCAL cProtoAt		:= Space(08)
LOCAL cFase			:= Space(01)                          
LOCAL cOpcFase		:= "" 
LOCAL dDatPagto     := CToD("")
LOCAL oGrupo
LOCAL oCombFase                                                
LOCAL oSayTipo  
LOCAL oSay
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
DEFINE MSDIALOG oDlg TITLE STR0026 FROM 008.2,008.3 TO 023, 054 OF GetWndDefault() //"Filtro dos Atendimentos"

@ 016, 005  TO 105, 179 PIXEL OF oDlg LABEL 'Filtros' 

@ 040, 026 SAY  STR0027 PIXEL OF oDlg //"Mes de: "
@ 040, 048 MSGET oSay VAR cMesDe SIZE 010,008 PIXEL OF oDlg
@ 040, 091 SAY  STR0028 PIXEL  OF oDlg //"Mes ate: "
@ 040, 114 MSGET oSay VAR cMesAt SIZE 010,008 PIXEL OF oDlg

@ 057, 026 SAY  STR0029 PIXEL OF oDlg //"Ano de: "
@ 057, 048 MSGET oSay VAR cAnoDe SIZE 010,008 PIXEL OF oDlg
@ 057, 091 SAY  STR0030 PIXEL  OF oDlg //"Ano ate: "
@ 057, 114 MSGET oSay VAR cAnoAt SIZE 010,008 PIXEL OF oDlg

@ 074, 008 SAY  STR0033 PIXEL OF oDlg //"Atendimento de: "
@ 074, 048 MSGET oSay VAR cProtoDe SIZE 010,008 PIXEL OF oDlg
@ 074, 102 SAY  STR0034 PIXEL  OF oDlg //"Ate: "
@ 074, 114 MSGET oSay VAR cProtoAt SIZE 010,008 PIXEL OF oDlg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa a dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro dinamico...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
If nOpca == K_OK
 	
	For nFor :=1 To 7
		If nFor == 1 
			If !Empty(cMesDe) .or. !Empty(cMesAt)
				cFiltro += "AND B0R_MESPRO >= '" + AllTRIM(cMesDe) + "' "
				cFiltro += "AND B0R_MESPRO <= '" + AllTRIM(cMesAt) + "' "
			Endif
		ElseIf nFor == 2 
			If !Empty(cAnoAt)
			    cFiltro += "AND B0R_ANOPRO >= '" + AllTRIM(cAnoDe) + "' "
				cFiltro += "AND B0R_ANOPRO <= '" + AllTRIM(cAnoAt) + "' "
		   EndIf
		ElseIf nFor == 3
			If !Empty(cProtoAt)
			    cFiltro += "AND B0R_CODIGO >= '" + AllTRIM(cProtoDe) + "' "
				cFiltro += "AND B0R_CODIGO <= '" + AllTRIM(cProtoat) + "' "
			EndIf 
	    EndIf
	Next
   
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Return({IF(nOpca==K_OK,.T.,.F.),cFiltro })

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa	 ³ PL552VPar  ³ Autor ³ Michel Montoro    ³ Data ³ 17.12.12   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o conteúdo dos parâmetros necessários para a rotina ³±±
±±³          ³ de Ressarcimento SUS	                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 						                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL552VPar(cParam)
LOCAL lRet		:= .T.
LOCAL MVRESSSUS	:= GetMv("MV_TABSSUS")	//MV_TABSSUS	- 08		- XML
LOCAL MVCDTUNEP	:= GetMv("MV_CDTUNEP")	//MV_CDTUNEP	- 0001010	- XML
LOCAL MVRDASUS	:= GetMv("MV_RDASUS")	//MV_RDASUS		- 000011	- XML e 552
LOCAL MVCDLCSUS	:= GetMv("MV_CDLCSUS")	//MV_CDLCSUS	- 5000		- 552
LOCAL cIntPad 	:= PLSINTPAD()

DEFAULT cParam := ""

If lRet .AND. ( EMPTY(cParam) .OR. "MV_TABSSUS" $ cParam)
	If Empty(MVRESSSUS) 
		lRet := .F.
	Else
   		dbSelectArea("BR4")
		dbSetOrder(1) //BR4_FILIAL + BR4_CODPAD + BR4_SEGMEN
		lRet := BR4->(MsSeek(xFilial("BR4")+MVRESSSUS))
	EndIf
	If !lRet
		MsgInfo(STR0042) //"Verifique o conteúdo do parâmetro "MV_TABSSUS, que deve estar preenchido com o código do 'Tipo de Tabela' referente ao SUS."
	EndIf
EndIf
If lRet .AND. ( EMPTY(cParam) .OR. "MV_CDTUNEP" $ cParam )
	If Empty(MVCDTUNEP) 
		lRet := .F.
	Else
   		dbSelectArea("BF8")
		dbSetOrder(1) //BF8_FILIAL+BF8_CODINT+BF8_CODIGO
		lRet := BF8->(MsSeek(xFilial("BF8")+MVCDTUNEP))
	EndIf
	If !lRet
		MsgInfo(STR0043) //"Verifique o conteúdo do parâmetro MV_CDTUNEP, que deve estar preenchido com a Operadora + 'Tabela Dinamica de Eventos' referente ao SUS."
	EndIf
EndIf
If lRet .AND. ( EMPTY(cParam) .OR. "MV_RDASUS" $ cParam )
	If Empty(MVRDASUS) 
		lRet := .F.
	Else
   		dbSelectArea("BAU")
		dbSetOrder(1) //BAU_FILIAL + BAU_CODIGO
		lRet := BAU->(MsSeek(xFilial("BAU")+MVRDASUS))
	EndIf
	If !lRet
		MsgInfo(STR0044) //"Verifique o conteúdo do parâmetro MV_RDASUS, que deve estar preenchido com a Rede de Atendimento referente ao SUS."
	EndIf
EndIf
If lRet .AND. ( EMPTY(cParam) .OR. "MV_CDLCSUS" $ cParam )
	If Empty(MVCDLCSUS) 
		lRet := .F.
	Else
   		dbSelectArea("BCG")
		dbSetOrder(1) //BCG_FILIAL + BCG_CODLDP + BCG_CODOPE
		lRet := BCG->(MsSeek(xFilial("BCG")+MVCDLCSUS+cIntPad))
	EndIf
	If !lRet
		MsgInfo(STR0045) //"Verifique o conteúdo do parâmetro MV_CDLCSUS, que deve estar preenchido com o Local Padrão de digitacao para as guias referente ao SUS."
	EndIf
EndIf
		
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA552ANA ³ Autor ³ Michel Montoro    ³ Data ³ 18.01.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Rotina para analisar os registros com status = 2			  ³±±
±±³          ³ (incompletos). Analisa Beneficiário e Procedimentos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Padrao do mBrowse                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA552ANA(cAlias,nReg,nOpc)
LOCAL aRetBene	:= {}
LOCAL aRetProc	:= {}
LOCAL aCritic	:= {}
LOCAL lIncompl	:= .T.
LOCAL lCritic	:= .F.
LOCAL lExiMSG	:= .F.

If B0R->B0R_STATUS <> "2"
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Beneficiário...												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aRetBene := PLA553Ben(B0R->B0R_CODCCO, B0R->B0R_DATNAS)
If aRetBene[1][1]
	RecLock("B0R", .F.)
		B0R->B0R_USUARI:= aRetBene[02]	// Chave - oXmlBENE:_codigoBeneficiario
		B0R->B0R_CODEMP:= aRetBene[03]	// BA1_CODEMP
		B0R->B0R_MATRIC:= aRetBene[04]	// BA1_MATRIC
		B0R->B0R_TIPREG:= aRetBene[05]	// BA1_TIPREG
		B0R->B0R_CPFUSR:= aRetBene[06]	// BA1_CPFUSR
		B0R->B0R_IDUSR := aRetBene[07]	// BA1_DRGUSR
		B0R->B0R_DIGITO:= aRetBene[08]	// BA1_DIGITO
		B0R->B0R_CONEMP:= aRetBene[09]	// BA1_CONEMP
		B0R->B0R_VERCON:= aRetBene[10]	// BA1_VERCON
		B0R->B0R_SUBCON:= aRetBene[11]	// BA1_SUBCON
		B0R->B0R_VERSUB:= aRetBene[12]	// BA1_VERSUB
		B0R->B0R_MATVID:= aRetBene[13]	// BA1_MATVID
		B0R->B0R_NOMUSR:= aRetBene[14]	// BA1_NOMUSR
		B0R->B0R_MATUSA:= "1"			// 1=Matricula Principal; 2=Matricula Antiga
		B0R->B0R_STATUS:= "1"
	B0R->(MsUnlock())
Else
	If lExiMSG
		MsgInfo( aRetBene[1][2],"Atenção" )
	Else
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetBene[1][2] , 0, 0, {})
	EndIf
	lCritic := .T.
	aADD(aCritic,{"Beneficiário não Encontrado",aRetBene[1][2]})
	lIncompl := .F.					
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Procedimentos...												 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B0W->(DbSetOrder(1))
B0W->(DbSeek(xFilial("B0W")+PLSINTPAD()+B0R->B0R_CODIGO))
While (! B0W->(Eof())) .And. B0W->B0W_CODIGO == B0R->B0R_CODIGO

	aRetProc := PLA553Pro(B0W->B0W_CDPADP,B0W->B0W_TUNEP)
	If aRetProc[1]
	
		RecLock("B0W", .F.)
			B0W->B0W_CODPAD	:= aRetProc[2]
			B0W->B0W_CODPRO	:= aRetProc[3]
			B0W->B0W_STATUS	:= "1"
		B0W->(MsUnlock())
	
	Else
		If lExiMSG
			MsgInfo(aRetProc[LEN(aRetProc)],"Atenção" )
		Else
			FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "PLSA553: "+aRetProc[LEN(aRetProc)] , 0, 0, {})
		EndIf
		lCritic := .T.
		aADD(aCritic,{"Procedimento não Encontrado",aRetProc[LEN(aRetProc)]})
		lIncompl := .F.
	EndIf
	
	B0W->(DbSkip())
EndDo

If !EMPTY(aCritic) .AND. lIncompl == .F. .AND. lCritic == .T.
	RecLock("B0R", .F.)
		B0R->B0R_STATUS	:= "2"
	B0R->(MsUnlock())

	PLSCRIGEN(aCritic,{ {"CAMPO","@C",90} , {"CRITICA","@C",80 } },"RESUMO DE CRÍTICAS")	
EndIf
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLS552SEQ ³ Autor ³ Luzio Tavares         ³ Data ³ 18.06.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria Sequencia											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS552SEQ

LOCAL cRet
If ValType(oBrwB0W) == "O"
	cRet := PLSINCRE("B0W_SEQUEN",oBrwB0W)
Else
	cRet := PLSINCRE("B0W_SEQUEN")
Endif

Return(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLA552BD6  ³ Autor ³ Michel Montoro    ³ Data ³ 18.01.13   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta get do folder de procedimentos do Ressarcimento      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PLSA552                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLA552BD6(aArrayBD6,aHeadB0W)
LOCAL aBackB0W  := {}
LOCAL aColsB0W 	:= {}
LOCAL nFor		:= 0

For nFor := 1 TO LEN(aArrayBD6)
	
	Store Cols Blank "BE2" TO aColsB0W FROM aHeadB0W
	
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_FILIAL"})
	aColsB0W[1][nPos] := xFilial("BE2")
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_OPEUSR"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][17][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODEMP"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][02][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_MATRIC"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][03][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_TIPREG"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][04][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_DIGITO"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][05][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_MATVID"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][42][2], aColsB0W[nFor][nPos])	
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_NOMUSR"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][44][2], aColsB0W[nFor][nPos])	
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_OPEMOV"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][01][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_ANOAUT"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][22][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_MESAUT"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][21][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_SEQUEN"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][39][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_OPERDA"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][23][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODRDA"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][24][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODPAD"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][07][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODPRO"})	
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][06][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_DESPRO"})	
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][43][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_QTDPRO"}) 
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][09][2], aColsB0W[nFor][nPos])	
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_VLRAPR"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][15][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_NUMAUT"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][41][2], aColsB0W[nFor][nPos])	
    nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_TIPO"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][45][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODLOC"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][46][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_LOCAL"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][47][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_DESLOC"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][48][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_ENDLOC"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][49][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_CODESP"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][08][2], aColsB0W[nFor][nPos])
	nPos := aScan(aHeadB0W, {|x| alltrim(x[2]) = "BE2_DATPRO"})
	aColsB0W[1][nPos] := IIf (nPos > 0, aArrayBD6[nFor][18][2], aColsB0W[nFor][nPos])
		
	aAdd(aBackB0W,aColsB0W[01])
Next nFor

Return (aBackB0W)
