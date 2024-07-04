#INCLUDE "TMSa730.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA730  ³ Autor ³Patricia A. Salomao    ³ Data ³15.07.2003   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Geracao de Novos Contratos de Prestacao de Servico (Fornecedor)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA730()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA730()

Local cArqTRB,cFilDUJ, cSeek
Local nIndex, nX, nSeek, nSeek1
Local aAreaDUJ  := DUJ->(GetArea())
Local aObjects	 := {}
Local aInfo 	 := {}
Local aSize     := {}
Local aAlter    := {}
Local nOpcA     := 0
Local oDlg, oGet
Local nPosItem, nPosSerTms, nPosTipTra
Local aFldDVG		:= {}
Local aHeaderDVG	:= {}
Local nI			:= 0
Local nPos			:= 0

Private aDadosDVG := {}
Private aDadosDUJ := {}
Private aHeader   := {}
Private aCols     := {}
Private nPosTabCar, nPosTabFre, nPosTipTab
Private Inclui    := .F.

//aRotina para criacao da GetDados.
aRotina	:= {	{ STR0001	,"" ,0,1 },; //"Pesquisar"
					{ STR0002	,"" ,0,2 },; //"Visualizar"
					{ STR0003	,"" ,0,3 },; //"Incluir"
					{ STR0004	,"" ,0,4 },; //"Alterar"
					{ STR0005	,"" ,0,5 }}  //"Excluir"

aFldDVG := ApBuildHeader("DVG")
aHeaderDVG = {"DVG_ITEM", "DVG_SERTMS", "DVG_DESSVT", "DVG_TIPTRA", "DVG_DESTPT", "DVG_TABCAR", "DVG_TABFRE", "DVG_TIPTAB"}

For nI := 1 To Len(aHeaderDVG)
	If (nPos := aScan(aFldDVG, {|x| AllTrim(x[2]) == aHeaderDVG[nI]})) > 0
		aAdd(aHeader, aFldDVG[nPos])
	EndIf
Next

nPosItem   := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_ITEM' })
nPosSerTms := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_SERTMS' })
nPosTipTra := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_TIPTRA' })
nPosTabCar := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_TABCAR' })
nPosTabFre := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_TABFRE' })
nPosTipTab := Ascan(aHeader, {|x| AllTrim(x[2]) == 'DVG_TIPTAB' })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Data Novo Contrato  ?                             ³
//³ mv_par02 - Servico Transporte De  ?                          ³
//³ mv_par03 - Servico Transporte Ate ?                          ³
//³ mv_par04 - Tipo Transporte De  ?                             ³
//³ mv_par05 - Tipo Transporte Ate ?                             ³
//³ mv_par06 - Fornecedor De  ?                                  ³
//³ mv_par07 - Loja De  ?                                        ³
//³ mv_par08 - Fornecedor Ate ?                                  ³
//³ mv_par09 - Loja Ate ?                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Pergunte('TMA730',.T.)
	Return .T.
EndIf

cArqTRB := CriaTrab(Nil,.F.)

dbSelectArea("DUJ")

cFilDUJ :='DUJ_FILIAL=="'+xFilial("DUJ") +'".And.Empty(DUJ_FIMVIG).And.DTOS(DUJ_INIVIG)<="'+ DTOS(date())+;
'".And. DUJ_CODFOR >="'+mv_par06+'".And. DUJ_LOJFOR >="'+mv_par07+;
'".And. DUJ_CODFOR <="'+mv_par08+'".And. DUJ_LOJFOR <="'+mv_par09+'"'

IndRegua("DUJ",cArqTRB,IndexKey(),,cFilDUJ, STR0006) //"Selecionando Registros..."

nIndex := RetIndex("DUJ")
dbSetOrder(nIndex+1)
dbGoTop()

If !Eof()

	While !Eof()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³aDadosDUJ : Guarda todos os Contratos que serao Encerrados    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do Array aDadosDUJ:                                ³
		//³ 1a. Posicao - No. do Registro (DUJ)                          ³
		//³ 2a. Posicao - No. do Contrato a ser Encerrado                ³
		//³ 3a. Posicao - No. do Novo Contrato a ser Gerado              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AAdd(aDadosDUJ, {Recno(), DUJ->DUJ_NCONTR, ""} )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche aCols com os dados da tabela selecionada ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DVG->(dbSetOrder(1))
		DVG->(MsSeek(cSeek:=xFilial("DVG")+DUJ->DUJ_NCONTR))
		While !DVG->(Eof())  .And. DVG->(DVG_FILIAL+DVG_NCONTR) == cSeek
			If DVG->DVG_SERTMS >= mv_par02 .And. DVG->DVG_SERTMS <= mv_par03 .And.;
				DVG->DVG_TIPTRA >= mv_par04 .And. DVG->DVG_TIPTRA <= mv_par05
				
				nSeek1 := Ascan( aCols, {|x| x[nPosSerTMS]+x[nPosTipTra]+x[nPosTabCar]+x[nPosTabFre]+x[nPosTipTab] == ;
				DVG->(DVG_SERTMS+DVG_TIPTRA+DVG_TABCAR+DVG_TABFRE+DVG->DVG_TIPTAB) } )
				
				If nSeek1 == 0
					
					AAdd(aCols,Array(Len(aHeader)+1))
					
					For nX := 1 to Len(aHeader)
						If	aHeader[nX,10] != "V"
							aCols[Len(aCols),nX]:=DVG->(FieldGet(FieldPos(aHeader[nX,2])))
						Else
							aCols[Len(aCols),nX]:=CriaVar(aHeader[nX,2])
						EndIf
					Next nX
					
					aCols[Len(aCols)][nPosItem] 		  := StrZero(Len(aCols),Len(DVG->DVG_ITEM))
					aCols[Len(aCols)][Len(aHeader)+1] := .F.
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³aDadosDVG : Guarda o No. dos Contratos que estao contidos em  ³
					//³cada linha do aCols                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Estrutura do Array aDadosDVG:                                ³
					//³ 1a. Posicao - No. do Item no aCols                           ³
					//³ 2a. Posicao - Array contendo todos os Registros do DVG / Nos.³
					//³            dos Contratos que estao contidos na linha do aCols³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					AAdd(aDadosDVG, {aCols[Len(aCols)][nPosItem] } )
					AAdd(aDadosDVG[Len(aDadosDVG)],{})
					AAdd(aDadosDVG[Len(aDadosDVG)][2], {DVG->(Recno()), DVG->DVG_NCONTR})
					
				Else
					
					//-- Adiciona na linha do aCols, o Registro do DVG e o No. do Antigo Contrato
					nSeek := Ascan(aDadosDVG, {|x| x[1] == aCols[nSeek1][nPosItem] })
					AAdd(aDadosDVG[nSeek][2], {DVG->(Recno()), DVG->DVG_NCONTR})
					
				EndIf
				
			EndIf
			
			DVG->(dbSkip())
		EndDo
		DUJ->(dbSkip())
	EndDo
	
	If !Empty(aCols)

		// Reordena os Itens do aCols
		aCols:=aSort( aCols,,, { | x , y | x[2]+x[4]+x[5]+x[6]+x[7] < y[2]+y[4]+y[5]+y[6]+y[7] } )
		For nX:=1 to Len(aCols)
			nSeek := Ascan(aDadosDVG, {|x| x[1] == aCols[nX,1]} )
			aDadosDVG[nSeek][1] := StrZero(nX,2)
			aCols[nX,1] := StrZero(nX,2)
		Next
		
		AAdd(aAlter, "DVG_TABCAR")
		AAdd(aAlter, "DVG_TABFRE")
		AAdd(aAlter, "DVG_TIPTAB")
		
		//-- Calcula as dimensoes dos objetos
		aSize  := MsAdvSize( .T. )
		
		AAdd(aObjects,{100,100,.T.,.T.})
		aInfo		:= { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
		aPosObj	:= MsObjSize( aInfo, aObjects, .T. )
		
		DEFINE MSDIALOG oDlg FROM aSize[7],0 TO aSize[6],aSize[5] TITLE STR0007 PIXEL //'Geracao de Novos Contratos de Fornecedor'
		
		oGet:= MSGetDados():New(aPosObj[ 1, 1 ], aPosObj[ 1, 2 ],aPosObj[ 1, 3 ], aPosObj[ 1, 4 ],4 ,"TMSA730LinOk","AlwaysTrue",,.F.,aAlter,,.F.,Len(aCols),,,,,oDlg)
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpcA:=1, If(TMSA730LinOk(),oDlg:End(),nOpcA := 0)},{||oDlg:End()})
		
		If	nOpcA == 1
			Processa({|lEnd| Tms730Proc(@lEnd)},,,.T.)
		EndIf

	Else
		Help("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	EndIf
	
Else
	Help("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
EndIf

If File(cArqTRB + OrdBagExt())
	RetIndex("DUJ")
	Ferase(cArqTRB + OrdBagExt())
EndIf

RestArea( aAreaDUJ )

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSA730LinO³ Autor ³Patricia A. Salomao    ³ Data ³15.07.2003   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida a Linha da GetDados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA730LinOk()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³logico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaTMS - Gestao de Transporte                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA730LinOk()

If Empty(aCols[n][nPosTabCar]) .And. Empty(aCols[n][nPosTabFre])
	Help("",1,"TMSA73001") // E' Obrigatorio Informar a Tabela de Carreteiro ou a Tabela de Frete
	Return ( .F. )
EndIf

If !Empty(aCols[n][nPosTabCar]) .And. !Empty(aCols[n][nPosTabFre])
	Help("",1,"TMSA73002") // Nao e' permitido informar a Tabela de Carreteiro e a Tabela de Frete ...
	Return ( .F. )
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³TMSA730Proc³ Autor ³Patricia A. Salomao    ³ Data ³15.07.2003   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera os Novos Contratos e Encerra a Vigencia dos Contratos An-  ³±±
±±³          ³teriores                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA730Proc()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SigaTMS - Gestao de Transporte                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMS730Proc()

Local nX, nZ
Local aCampos      := {}
Local cOldContrat  := ""
Local cNewContrat  := ""
Local dDataNvContr := mv_par01
Local nSeekDVG, nSeekDUJ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aDadosDUJ : Guarda todos os Contratos que serao Encerrados    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aDadosDUJ:                                ³
//³ 1a. Posicao - No. do Registro (DUJ)                          ³
//³ 2a. Posicao - No. do Contrato a ser Encerrado                ³
//³ 3a. Posicao - No. do Novo Contrato a ser Gerado              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³aDadosDVG : Guarda o No. dos Contratos que estao contidos em  ³
//³cada linha do aCols                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura do Array aDadosDVG:                                ³
//³ 1a. Posicao - No. do Item no aCols                           ³
//³ 2a. Posicao - Array contendo todos os Registros do DVG / Nos.³
//³            dos Contratos que estao contidos na linha do aCols³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX :=1 To Len(aCols)
	
	//-- Posiciona no Array aDadosDVG, conforme item do aCols
	nSeekDVG := Ascan(aDadosDVG, {|x| x[1] == aCols[nX][1] })
	
	//-- Varre todos os Contratos contidos na Linha do aCols
	For nZ :=1 To Len(aDadosDVG[nSeekDVG][2])
		
		//-- No. do Antigo Contrato
		cOldContrat := aDadosDVG[nSeekDVG][2][nZ][2]
		
		//-- Pesquisa no Array aDadosDUJ o Contrato Antigo, para pegar o no. do Registro no arquivo
		//-- DUJ e verificar se ja foi gerado um novo contrato para ele.
		nSeekDUJ := Ascan(aDadosDUJ, {|x| x[2] == cOldContrat })
		
		//-- Pega o no. do Registro do Contrato Antigo e posiciona no Arquivo DUJ
		DUJ->(MsGoTo(aDadosDUJ[nSeekDUJ][1]))		     		
		
		//--  Verifica se ja foi gerado um Contrato Novo para substituir o Contrato Antigo
		If Empty(aDadosDUJ[nSeekDUJ][3]) // No. do Novo Contrato
			
			cNewContrat := GetSX8Num( "DUJ", "DUJ_NCONTRT" )  // Armazena o No do Novo Contrato
			If __lSX8
				ConfirmSX8()
			EndIf
			
			//-- Guarda no Array aDadosDUJ o No. do Novo Contrato que sera gerado
			aDadosDUJ[nSeekDUJ][3] := cNewContrat
			                    
			If DUJ->DUJ_INIVIG == dDataBase
				dDataNvContr:=mv_par01+1
			EndIf             
			
			//-- Campos a serem alterados para o Novo Contrato
			aCampos := {}
			AAdd(aCampos, {'DUJ_NCONTR', cNewContrat } ) // Novo No. do Contrato
			AAdd(aCampos, {'DUJ_INIVIG', dDataNvContr} ) // Inicio da Vigencia do Novo Contrato
			AAdd(aCampos, {'DUJ_FIMVIG', CTOD('  /  /  ')} ) // Fim da Vigencia do Novo Contrato
			
			//-- Gera Novo Contrato
			DUJ->(TmsCopyReg(aCampos))
			
			//-- Grava Fim da Vigencia do Contrato Antigo
			RecLock("DUJ", .F.)									
			DUJ->DUJ_FIMVIG := dDataNvContr - 1 
			DUJ->(MsUnLock())
			
		Else
			
			//-- Se ja foi gerado um Novo Contrato no Arquivo DUJ, pega este Numero e Gera
			//-- somente os Itens do Novo Contrato (DVG)
			cNewContrat := aDadosDUJ[nSeekDUJ][3]
			
		EndIf
		
		//-- Campos a serem alterados para o Novo Contrato
		aCampos     := {}
		AAdd(aCampos,{'DVG_NCONTR',cNewContrat })
		AAdd(aCampos,{'DVG_TABFRE',GdFieldGet('DVG_TABFRE', nX) })
		AAdd(aCampos,{'DVG_TIPTAB',GdFieldGet('DVG_TIPTAB', nX) })
		AAdd(aCampos,{'DVG_TABCAR',GdFieldGet('DVG_TABCAR', nX) })
		
		DVG->(MsGoTo(aDadosDVG[nSeekDVG][2][nZ][1])) // Registro do DVG a ser copiado
		DVG->(TmsCopyReg(aCampos))
	Next nZ
	
Next nX

Return .T.                              

