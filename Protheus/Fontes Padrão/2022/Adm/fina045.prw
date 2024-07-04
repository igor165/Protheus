#INCLUDE "FINA045.CH"
#INCLUDE "PROTHEUS.CH"
//TESTE PHOENIX

Static _oFINA0451
Static _oFINA0452
Static __cMarca As Character

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA045   บAutor  ณRicardo Farinelli   บ Data ณ  12/18/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a substituicao de titulos automatica para os clientesบฑฑ
ฑฑบ          ณque compram periodicamente.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Sigavei e Sigaofi                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA045(aRotAuto)

LOCAL nHdlLock  := 0 			
LOCAL cAlias 	 := ""
LOCAL cIndex 	 := ""
LOCAL cChave 	 := ""
LOCAL cFor      := ""
LOCAL cAliasE1  := ""
LOCAL cIndexE1	 := ""
LOCAL cChaveE1	 := ""
LOCAL cForE1    := ""
LOCAL cAliasTRB := ""
LOCAL cIndexTRB := ""
LOCAL cChaveTRB := ""
LOCAL cForTRB   := ""
Local lPanelFin := IsPanelFin()
Local cTipper   := SuperGetMV("MV_TIPPER")
Local cNatPer   := SuperGetMV("MV_NATPER")

PRIVATE oMark		:= 0
PRIVATE nIndexSE1 := 0 // guarda a ordem do novo indice criado no filtro do criatrab
PRIVATE aAutoCab  := aRotAuto
PRIVATE lF045Auto := IIF(aRotAuto <> NIL , .T. , .F. ) 

__cMarca := GetMark()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Restringe o uso do programa ao Financeiro, Sigaloja e Especiaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !(AmIIn(6,11,12,14,41,72,97)) .AND. !lF045Auto	// Sข Fin , Veiculos, Loja, Oficina , Pecas, PHOTO e Esp
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ A ocorrencia 23 (ACS), verifica se o usuario poder  ou no   ณ
//ณ efetuar substituio de ttulos provisขrios.					  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF !ChkPsw( 23 ) .AND. !lF045Auto	
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se data do movimento no  menor que data limite de ณ
//ณ movimentacao no financeiro    										  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !DtMovFin(,,"2")
	Return
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณEsta fun็ใo foi desenvolvida ap๓s a gera็ใo do CD da 5.08.ณ
//ณPortanto os campos e parโmetros sใo verificados antes de  ณ
//ณpossibilitar rodar este processo.                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !ChkField()
	Return
Endif

If lPanelFin
	If !PergInPanel("FINA45",.T.)
		Return
	Endif
ElseIf !pergunte("FINA45",.T.)
	Return
Endif

// Cria indregua  no SE1
F045SE1(@cAliasE1,@cIndexE1,@cChaveE1,@cForE1)

// Cria indregua no SA1
If F045SA1(@cAlias,@cIndex,@cChave,@cFor)
	 // Cria a Tabela Base de Trabalho do SA1 + campo A1_OK para a Markbrowse	
	F045TRB(@cAliasTRB,@cIndexTRB,@cChaveTRB,@cForTRB)
	// Sinaliza a execucao de susbstituicao de titulos (fina040)	
	If F045SMF(@nHdlLock) 
		If !lF045Auto			
			// Mostra a Markbrowse para escolha dos clientes a substituir titulos		
			F045TEL(lPanelFin,@cIndexE1) 
		Else
			//Executa direto a fun็ใo de processamento	
			F045GRV(.F.,@cIndexE1)
		Endif
	Endif
Endif

// deleta os arquivos temporarios

If(_oFINA0451 <> NIL)
	_oFINA0451:Delete()
	_oFINA0451 := NIL
EndIf

If(_oFINA0452 <> NIL)
	_oFINA0452:Delete()
	_oFINA0452 := NIL
EndIf

dbSelectArea("SA1")
dbCloseArea()

cIndex:=""
dbSelectArea("SE1")
dbCloseArea()

cIndexE1:=""
If Select("TRBSE1")>0
	dbSelectArea("TRBSE1")
	dbCloseArea()
	Ferase(cIndexTRB+GetDBExtension())
	cIndexMB:=""
Endif
If Select("SA1TRB")>0
	dbSelectArea("SA1TRB")
	dbCloseArea()
	Ferase(cIndexTRB+GetDBExtension())
	cIndexMB:=""
Endif

If nHdlLock > 0
	Fclose(nHdlLock)
	Ferase("FINA040.LCK")
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045SE1   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria indice temporario no se1 selecionando apenas os titulosบฑฑ
ฑฑบ          ณprovisorios.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F045SE1(cAliasE1,cIndexE1,cChaveE1,cForE1)

Dbselectarea("SE1")
cAliasE1 := "SE1"
cIndexE1 := CriaTrab(nil,.f.)
cChaveE1 := "E1_FILIAL+E1_CLIENTE+E1_LOJA"
If Empty(MV_PAR02)
	cForE1   := 'E1_TIPO$"'+MVPROVIS+'"' // Seleciona apenas os provisorios
Else
	cForE1   := '(E1_TIPO$"'+MVPROVIS+'" .or. (E1_TIPO$"'+MV_PAR02+'" .and. E1_VALOR==E1_SALDO))' // Seleciona os provisorios e o tipo escolhido pelo usuario
Endif
cForE1 += ".and.Empty(E1_PORTADO)"
cForE1 += ".and.!('MATA'$E1_ORIGEM)"
//Template GEM - nao podem ser renegociados os titulos do GEM no financeiro.
If HasTemplate("LOT")
	cForE1 += ".and.Empty(E1_NCONTR)"
EndIf

// Adicionado para Atender Shark - 12/01/10
If ExistBlock("FA045FIL") 
   cForE1 += ExecBlock("FA045FIL",.F.,.F.)
EndIf


IndRegua(cAliasE1,cIndexE1,cChaveE1,,cForE1,STR0002) //"Selecionando Registros"
nIndexE1 := RetIndex("SE1")
dbSelectArea(cAliasE1)


dbSetOrder(nIndexE1+1)
nIndexSE1 := nIndexE1+1
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045SA1   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria indice temporario de forma a separar apenas os clientesบฑฑ
ฑฑบ          ณque atendem o periodo desejado e que possuam tituls proviso-บฑฑ
ฑฑบ          ณrios a serem gerados titulos efetivos.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstitucao de Titulos Automatica                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045SA1(cAlias,cIndex,cChave,cFor)
Local LRet := .f.
Local cDiaFer := Str(Day(cTod("01/03/"+Str(Year(MV_PAR01),4))-1),2) //Ultimo dia de Fevereiro
Local nLaco := 0


cFor := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณesta funcao tem como objetivo determinar quais os periodosณ
//ณse enquadram na data digitada.                            ณ
//ณperiodos:      02 - toda segunda feira                    ณ
//ณ               03 - toda terca feira                      ณ
//ณ               04 - toda quarta feira                     ณ
//ณ               05 - toda quinta feira                     ณ
//ณ               06 - toda sexta feira                      ณ
//ณ               10 - decendial                             ณ
//ณ               15 - quinzenal                             ณ
//ณ               30 - mensal                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DbSelectArea("SA1")
DbSetOrder(1)
cQuery := "SELECT * "
cQuery += "FROM "+RetSqlName("SA1")+" SA1 "
cQuery += "WHERE SA1.A1_COND <>'"+Space(Len(SA1->A1_COND))+"' AND "
cQuery += "SA1.A1_FILIAL='"+xFilial("SA1")+"' AND "
If Str(Day(MV_PAR01),2)$"10/20/30"
	cQuery += "SA1.A1_TIPPER IN ('10','15','30') OR "
Elseif (Strzero(Month(MV_PAR01),2)$"01/03/05/07/08/10/12" .and. Str(Day(MV_PAR01),2)=="31") .or.;
		(Strzero(Month(MV_PAR01),2)$"04/06/09/11" .and. Str(Day(MV_PAR01),2)=="30") .or.;
		(Month(MV_PAR01)==2 .and. Str(Day(MV_PAR01),2)$cDiaFer)
		cQuery += "SA1.A1_TIPPER IN ('10','15','30') OR "
Elseif Str(Day(MV_PAR01),2)=="15"
		cQuery += "SA1.A1_TIPPER IN ('15','30') OR "
Elseif Str(Day(MV_PAR01),2)=="30"
		cQuery += "SA1.A1_TIPPER IN ('10','15') OR "
Endif
If Str(Dow(MV_PAR01),1)$"23456"
	cQuery += "SA1.A1_TIPPER = '"+Strzero(Dow(MV_PAR01),2)+"' AND "
Endif
cQuery += "SA1.D_E_L_E_T_= ' ' AND "	
cQuery += "EXISTS ( SELECT * "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
cQuery += "SE1.E1_CLIENTE = SA1.A1_COD AND "
//Template GEM - nao podem ser renegociados os titulos do GEM no financeiro.
cQuery += "SE1.E1_LOJA = SA1.A1_LOJA AND "
If HasTemplate("LOT")
	cQuery += "SE1.E1_NCONTR=' ' AND "
EndIf
cQuery += "(SE1.E1_TIPO IN "+FormatIn(MVPROVIS,"|")
If !Empty(MV_PAR02)
	cQuery += "OR (SE1.E1_TIPO ='"+mv_par02+"' AND SE1.E1_VALOR=SE1.E1_SALDO)"
Endif
	
cQuery += ") AND SE1.E1_ORIGEM NOT LIKE 'MATA%' AND SE1.D_E_L_E_T_= ' ' "

// ADicionado para Atender Shark - 12/01/10
If ExistBlock("FA045QRY") 
   cQuery += ExecBlock("FA045QRY",.F.,.F.)
EndIf

cQuery += " )"   // fechar o Exists do SQL Acima
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da ordem para Informix                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If UPPER(TcGetDB()) == "INFORMIX"
	cChave := ""
	For nLaco:=1 To FCount()
		If AllTrim(FieldName(nLaco)) $ ".A1_FILIAL.A1_COD.A1_LOJA"
			cChave += (StrZero(nLaco,2)+",")
		EndIf
	Next
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Descarta a ultima virgula da ordem gerada                       ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cChave := SubStr(cChave,1,Len(cChave)-1)
Else
	cChave := SqlOrder(IndexKey())
EndIf
cQuery += " ORDER BY " + cChave
cQuery := ChangeQuery(cQuery)			
dbSelectArea("SA1")
dbCloseArea()
dbSelectArea("SE1")
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SA1', .F., .T.)

dbGoTop()
If BOF() .and. EOF()
	Help(" ",1,"RECNO")
	lRet := .F.
ElseIf Empty(SA1->A1_COD) //Caso o campo A1_COD nao esteja preenchido nao devo continuar o processamento.
	MsgAlert(STR0062)
	lRet := .F.
ElseIf Empty(SA1->A1_TIPPER) //Caso o campo A1_TIPPER nao esteja preenchido nao devo continuar o processamento.
	MsgAlert(STR0063)
	lRet := .F.
Else
	lRet := .T.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045SMF   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVide codigo do FINA040.                                     บฑฑ
ฑฑบ          ณNao permite a execucao de substituicao por mais de um usua- บฑฑ
ฑฑบ          ณrio ao mesmo tempo.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F045SMF(nHdlLock)
If ( nHdlLock := MSFCREATE("FINA040.LCK") ) < 0
	MsgAlert(STR0003+chr(13)+chr(10)+;	  //"A Funcao de substituicao de titulos esta sendo utilizada por"
	STR0004+chr(13)+chr(10)+;	 //"outro usuario. Por questoes de integridade de dados, nao"
	STR0005+chr(13)+chr(10)+;	 //" permitida a utilizao desta rotina por mais de um usu rio"
	STR0006,STR0007)	 //"simultaneamente. Tente novamente mais tarde."###"Substituir"
	Return .F.
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Grava no sem foro informa”es sobre quem est  utilizando a Rotina  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
FWrite(nHdlLock,STR0008+cUserName+chr(13)+chr(10)+; //"Operador: "
STR0009+cEmpAnt+chr(13)+chr(10)+; //"Empresa.: "
STR0010+cFilAnt+chr(13)+chr(10)) //"Filial..: "

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045TEL   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta tela com a markbrowse para escolha dos clientes a se- บฑฑ
ฑฑบ          ณrem processados.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Substituicao de titulos automatica                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F045TEL(lPanelFin,cIndexE1)
Local nOpca   := 0
Local aCampos := {}
Local aDim	  := {}	
Local oEnc01
Local oPanelDados

DEFAULT lPanelFin := .F.

AADD(aCampos,{"A1_OK","","  ",""})
AADD(aCampos,{"A1_COD","","Codigo","@!"})
AADD(aCampos,{"A1_LOJA","",STR0011,"@!"}) //"Loja"
AADD(aCampos,{"A1_NOME","",STR0012,"@!"}) //"Nome Cliente"
AADD(aCampos,{"A1_COND","",STR0013,"@!"}) //"Condi็ใo de Pagamento"

If lPanelFin
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)		  
	DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0, 0 TO 0, 0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )
Else
	DEFINE MSDIALOG oDlg TITLE STR0014 FROM 9,0 To 28,80 OF oMainWnd   //"Selecione os clientes para gera็ใo dos tํtulos definitivos"
Endif

SA1TRB->(Dbgotop())
oMark:=MsSelect():New("SA1TRB","A1_OK",,aCampos,,__cMarca,{02,1,123,316})
oMark:oBrowse:lhasMark := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark := {|| Fina045Inverte(@oMark)}
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

If lPanelFin
	// posiciona dialogo sobre a celula
	oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
	oMark:oBrowse:REFRESH()	
	ACTIVATE MSDIALOG oDlg  ON INIT (FaMyBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpcA := 0,oDlg:End()}),	oMark:oBrowse:REFRESH())
	DbSelectArea("SE1")
	FinVisual("SE1",FinWindow,SE1->(Recno()))
Else

	DEFINE SBUTTON FROM 126,246.3 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 126,274.4 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED

Endif

If nOpca == 1
	F045GRVTIT(lPanelFin,@cIndexE1)
Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045TRB   บAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria arq.   temporario de forma a separar apenas os clientesบฑฑ
ฑฑบ          ณque atendem o periodo desejado e que possuam tituls proviso-บฑฑ
ฑฑบ          ณrios a serem gerados titulos efetivos,p/markbrowse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstitucao de Titulos Automatica                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function F045TRB(cAlias,cIndex,cChave,cFor)

Local aCampos := {}
AADD(aCampos,{"A1_OK","C",2,0})
AADD(aCampos,{"A1_COD","C",TamSX3("A1_COD")[1],0})
AADD(aCampos,{"A1_LOJA","C",TamSX3("A1_LOJA")[1],0})
AADD(aCampos,{"A1_NOME","C",TamSX3("A1_NOME")[1],0})
AADD(aCampos,{"A1_COND","C",TamSX3("A1_COND")[1],0})

//Dbselectarea("SA1")
cAlias := "SA1TRB"

// Criando o Objeto de ArqTemporario  
_oFINA0451 := FwTemporaryTable():New("SA1TRB")

// Criando a Strutura do objeto  
_oFINA0451:SetFields(aCampos)

// Criando o Indicie da Tabela
_oFINA0451:AddIndex("1",{"A1_COD","A1_LOJA"})

//////////////////////////////////
// Cria็ใo da tabela temporaria //
//////////////////////////////////
_oFINA0451:Create()

DbselectArea("SA1")
dbGoTop()

Do While !SA1->(Eof())
	RecLock("SA1TRB",.T.)
	SA1TRB->A1_COD     := SA1->A1_COD
	SA1TRB->A1_LOJA    := SA1->A1_LOJA
	SA1TRB->A1_NOME    := SA1->A1_NOME
	SA1TRB->A1_COND    := SA1->A1_COND
	MsUnLock()
	SA1->(dbskip())
Enddo

DbSelectArea("SA1")
//DbClearFil()
//RetIndex( "SA1" )
//dbSetOrder(1)

/*
If(_oFINA0451 <> NIL)
	_oFINA0451:Delete()
	_oFINA0451 := NIL
EndIf
*/

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045GRVTITบAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao dos novos titulos definitivos no contas a บฑฑ
ฑฑบ          ณreceber.                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045GRVTIT(lPanelFin,cIndexE1)
Processa({|lEnd| F045GRV(lPanelFin,@cIndexE1)},,STR0015) //"Gerando Titulos Efetivos"
Return

Function F045GRV(lPanelFin,cIndexE1)
LOCAL aProvis   := {} // para gardar a chave dos titulos a serem deletados
LOCAL nTotTit   := 0  // Somatoria dos titulos por cliente
LOCAL cPedido   := "" // numero do titulo a ser gerado
LOCAL dEmissao  := MV_PAR01             // data de emissao (geracao) dos titulos
LOCAL cTipTit   := GETMV("MV_TIPPER")  // Tipo de titulo a ser gerado
LOCAL cNatureza := GETMV("MV_NATPER")   // Codigo da natureza dos titulos a serem gerados
LOCAL cCondpag  := "" // codigo da condicao de pagamento padrao do cliente
LOCAL aPgto     := {} // array dos vencimentos e valores das parcelas a serem geradas
LOCAL cCli      := "" // Codigo do cliente a gerar titulos
LOCAL cLoja     := "" // Loja do cliente a gerar titulos
LOCAL cParc     := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" // sequencia de parcelas a serem geradas
LOCAL n         := 0
LOCAL nPosSA1   := 0
Local nOpca		 := 0
Local aTam		 := {}
Local aCampos	 := {}
LOCAL oMark 	 := 0
LOCAL lInverte  := .f.
Local lLast		 := .F. // Controla a leitura do ultimo registro do Arquivo TRBSE1
Local aCpos	 := {{ "TR_OK"		,, " "},; //"Rec."
						{ "TR_CLIENTE"	,, STR0026},; //"Cliente"
						{ "TR_LOJA"		,, STR0011},; //"Loja"
						{ "TR_PREFIXO"	,, STR0027},; //"Prefixo"
						{ "TR_NUM"		,, STR0028},; //"Numero"
						{ "TR_PARCELA"	,, STR0029},; //"Parcela"
						{ "TR_TIPO"		,, STR0030},; //"Tipo"
						{ "TR_VALOR"	,, STR0031,"@E 999,999,999.99"},; //"Valor"
						{ "TR_EMISSAO"	,, STR0032},; //"Emissao"
						{ "TR_VENCTO"	,, STR0033},; //"Vencto"
						{ "TR_VENCREA"	,, STR0034}} //"Vencto.Real"
Local aTamParc := TamSX3("E1_PARCELA")

Local aBut045 := {{"PESQUISA",{||Fa045Pesq(oMark)}, STR0042 ,STR0044}} //"Pesquisar..(CTRL-P)"###"Pesquisar"

Local aSize := {}
Local oPanel
Local aNewParcs := {}
Local cCliAuto  := ""
Local cLojAuto  := ""
Local lContinue := .F.

If lF045Auto
	//Carrega dados do array passados pelo MsExecAuto
	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_CLIENTE'})) > 0
		cCliAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_CLIENTE")[1])
 	EndIf	
	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_LOJA'})) > 0
		cLojAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_LOJA")[1])
 	EndIf	
 	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_PREFIXO'})) > 0
		cPrxAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_PREFIXO")[1])
 	EndIf	
  	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_NUM'})) > 0
		cNumAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_NUM")[1])
 	EndIf	
   	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_PARCELA'})) > 0
		cParAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_PARCELA")[1])
 	EndIf
   	If (nPosAuto := ascan(aAutoCab,{|x| Upper(x[1]) == 'E1_TIPO'})) > 0
		cTipAuto :=	PADR(aAutoCab[nPosAuto,2],TamSx3("E1_TIPO")[1])
 	EndIf
Endif

dbSelectArea("SE1")
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Gera arquivo de Trabalho                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCampos,{"TR_OK"		,"C",2,0})
atam := TamSX3("E1_CLIENTE")
AADD(aCampos,{"TR_CLIENTE"	,"C",aTam[1],0})
atam := TamSX3("E1_LOJA")
AADD(aCampos,{"TR_LOJA"		,"C",aTam[1],0})
AADD(aCampos,{"TR_PREFIXO"	,"C",3,0})
atam := TamSX3("E1_NUM")
AADD(aCampos,{"TR_NUM" 		,"C",aTam[1],0})
AADD(aCampos,{"TR_PARCELA"	,"C",aTamParc[1],0})
AADD(aCampos,{"TR_TIPO"		,"C",3,0})
atam := TamSX3("E1_VALOR")
AADD(aCampos,{"TR_VALOR" 	,"N",aTam[1],aTam[2]})
AADD(aCampos,{"TR_EMISSAO"	,"D",8,0})
AADD(aCampos,{"TR_VENCTO"	,"D",8,0})
AADD(aCampos,{"TR_VENCREA"	,"D",8,0})
AADD(aCampos,{"TR_TPREC"	,"C",1,0})

// Criando o Objeto de ArqTemporario  
_oFINA0452 := FwTemporaryTable():New("TRBSE1")

// Criando a Strutura do objeto  
_oFINA0452:SetFields(aCampos)

// Criando o Indicie da Tabela
_oFINA0452:AddIndex("1",{"TR_CLIENTE","TR_LOJA","TR_TPREC","TR_PREFIXO","TR_NUM","TR_PARCELA","TR_TIPO"})

//////////////////////////////////
// Cria็ใo da tabela temporaria //
//////////////////////////////////
_oFINA0452:Create()

SA1TRB->(Dbgotop())
ProcRegua(SA1TRB->(Reccount()))
Do While !SA1TRB->(Eof())
	IncProc(STR0016+SA1TRB->A1_NOME)     //"Analisando Cliente: "
	aProvis := {}
	nTotTit := 0
	cCondpag:= ""
	aPgto   := {}
	cCli    := ""
	cLoja   := ""
	
	If !lF045Auto
		cRegra1 := SA1TRB->A1_OK==__cMarca   // se foi selecionado na markbrowse
	Else
		cRegra1 := SA1TRB->A1_COD+SA1TRB->A1_LOJA == cCliAuto+cLojAuto
	Endif
		
	If cRegra1
		nPosSA1  := Recno()
		cCli     := SA1TRB->A1_COD
		cLoja    := SA1TRB->A1_LOJA
		Dbselectarea("SE1")
		DbSetOrder(nIndexSE1)
		Dbseek(xFilial("SE1")+cCli+cLoja)
		Do While SE1->E1_Filial+SE1->(E1_CLIENTE+E1_LOJA)==SE1->E1_Filial+SA1TRB->(A1_COD+A1_LOJA) .and. !SE1->(Eof())
		
			If SE1->E1_VENCTO > dEmissao   // pega somente os vencimentos ate a data da geracao dos titulos
				SE1->(Dbskip())
				Loop
			Endif

			If "MATA" $ SE1->E1_ORIGEM   // titulos vindos do faturamento sao desperezados
				SE1->(Dbskip())
				Loop
			Endif

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Grava o registro no arquivo Temporario           	  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			RecLock("TRBSE1" ,.T.)
			TRBSE1->TR_OK		:= __cMarca
			TRBSE1->TR_CLIENTE	:= SE1->E1_CLIENTE
			TRBSE1->TR_LOJA		:= SE1->E1_LOJA
			TRBSE1->TR_PREFIXO	:= SE1->E1_PREFIXO
			TRBSE1->TR_NUM		:= SE1->E1_NUM
			TRBSE1->TR_PARCELA	:= SE1->E1_PARCELA
			TRBSE1->TR_TIPO		:= SE1->E1_TIPO
			TRBSE1->TR_VALOR	:= SE1->E1_VALOR
			TRBSE1->TR_EMISSAO	:= SE1->E1_EMISSAO
			TRBSE1->TR_VENCTO	:= SE1->E1_VENCTO
			TRBSE1->TR_VENCREA	:= SE1->E1_VENCREA
			TRBSE1->TR_TPREC	:= "1" //Titulo Gerador
			MsUnlock()
			Dbselectarea("SE1")			
			SE1->(Dbskip())
		Enddo
	Endif
	SA1TRB->(Dbskip())
Enddo


While .T.
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Marca os titulos que farใo parte da renegociacao	  ณ
	//ณ Estes sao os titulos provisorios ou do tipo contido ณ
	//ณ em mv_par02 que serao deletados.                	  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nOpca := 0
	DbSelectArea("TRBSE1")
	dbGoTop() 
	IF BOF() .and. EOF()
		Help(" ",1,"RECNO")
		Exit
	Endif

	If !lF045Auto
	
		aSize:= MSADVSIZE()
		DEFINE MSDIALOG oDlg TITLE STR0001 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Substituicao Automatica de Titulos a Receber Provisorios"
		oDlg:lMaximized := .T.
	
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	
		oMark	:= MsSelect():New("TRBSE1","TR_OK","",aCpos,@lInverte,@__cMarca,{12,1,180,315})
		oMark:oBrowse:lColDrag := .T.  
		oMark:oBrowse:lhasMark = .t.
		oMark:oBrowse:lCanAllmark := .t.
		oMark:oBrowse:bAllMark := { || A045Inverte()}
		oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		
		If lPanelFin
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},aBut045)
		Else
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2,oDlg:End()},,aBut045)	
		Endif
	Else
		nOpca := 1
	Endif

	If nOpca == 1
		If !lF045Auto .and. !MsgYesNo(STR0058,STR0059) //"Confirma opera็ใo ?"###"Aten็ใo"
			Exit
		Endif						
		DbSelectArea("SE1")
		DbCloseArea()
		ChKFile("SE1")
		DbSelectArea("SE1")
		DbSetOrder(1)
		DbSelectArea("TRBSE1")
		dbGotop()
		ProcRegua(TRBSE1->(Reccount()))
		While !Eof() .and. !lLast
			dbSelectArea("TRBSE1")			
			IncProc(STR0057+TRBSE1->TR_CLIENTE)
			cCliente := TRBSE1->TR_CLIENTE+TRBSE1->TR_LOJA
			cPedido := ""
			aProvis := {}
			nTotTit := 0
			While !Eof() .and. TRBSE1->TR_CLIENTE+TRBSE1->TR_LOJA == cCliente
			
				If !lF045Auto
					cRegra2 := TRBSE1->TR_OK == __cMarca
				Else
					cRegra2 := TRBSE1->TR_PREFIXO == cPrxAuto .AND. TRBSE1->TR_NUM == cNumAuto .AND. TRBSE1->TR_PARCELA == cParAuto .AND. TRBSE1->TR_TIPO == cTipAuto
				Endif			
	
				If cRegra2
					// adiciona a chave para delecao dos titulos provisorios
					AADD(aProvis,{{"E1_PREFIXO",TR_PREFIXO,nil},;
					{"E1_NUM",TR_NUM,nil},;
					{"E1_PARCELA",TR_PARCELA,nil},;
					{"E1_TIPO",TR_TIPO,nil}})
	
					If Empty(cPedido) // Adiciona o primeiro numero de pedido que encontrar para assumir como numero de titulo
						cPedido := TRBSE1->TR_NUM
					Endif
					cCli    := TRBSE1->TR_CLIENTE
					cLoja   := TRBSE1->TR_LOJA
					nTotTit += TRBSE1->TR_VALOR
				Endif		
				TRBSE1->(Dbskip())
				nRecTRBSE1 := TRBSE1->(Recno())
			Enddo
			If nTotTit > 0
				If TRBSE1->(eof())
					lLast := .T.
				Endif
						
				DbSelectArea("SA1")
				DbCloseArea()
				ChKFile("SA1")
				DbSelectArea("SA1")
				DbSetOrder(1)
				dbSeek(xFilial("SA1")+cCliente)
				cCondpag := SA1->A1_COND
				aPgto := Condicao(nTotTit,cCondpag,,dEmissao) // Total para o calculo, cod. cond.pgto,data base
				aFin040 := {}
				DbselectArea("SE1")
				DbSetOrder(1)
				cParc := GetMv("MV_1DUP")
				cUltParc := TamParcela("E2_PARCELA","Z","ZZ","ZZZ")
				aNewParcs := {} //Novas parcelas a serem geradas
				For n := 1 to Len(aPgto)

					//Verifico parcelas existentes
					While .T. 
            		If SE1->(MsSeek(xFilial("SE1")+"BAL"+cPedido+cParc+cTipTit)).or. ;
							Ascan(aFin040,{|aVal| aVal[3,2] == cParc})>0
							If ( cParc == cUltParc )
								cParc := GetMv("MV_1DUP")
								cPedido  := Soma1(cPedido,Len(SE1->E1_NUM))
							Else
								cParc	:= Soma1(cParc,Len(SE1->E1_PARCELA))
							EndIf
							Loop
						Endif
						aadd(aNewParcs,cParc)
						Exit
					EndDo
				
					AADD(aFIN040,{ {"E1_PREFIXO","BAL",nil},;
						{"E1_NUM",cPedido,nil},;
						{"E1_PARCELA",cParc,nil},;
						{"E1_TIPO",cTipTit,nil},;
						{"E1_NATUREZ",cNatureza,nil},;
						{"E1_CLIENTE",cCli,nil},;
						{"E1_LOJA",cLoja,nil},;
						{"E1_EMISSAO",dDataBase,nil},;
						{"E1_VENCTO",aPgto[n,1],nil},;
						{"E1_VENCREA",aPgto[n,1],nil},;
						{"E1_VALOR",aPgto[n,2],nil} })
				Next			
				lMsErroAuto := .F. // variavel interna da rotina automatica	   	
				lMsHelpAuto := .F.	
				BEGIN TRANSACTION
					For n := 1 to len(aFIN040)
						MSExecAuto({|x,y| FINA040(x,y)},aFIN040[n],3)
						If lMsErroAuto
							MostraErro()
							Help(" ",1,"INCSUBPR",,cCli+"/"+cLoja,4,1) // Erro na Inclusao do Titulo do Contas a Receber
							DisarmTransaction()
							Break
						Endif
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Grava o registro no arquivo Temporario           	  ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						RecLock("TRBSE1" ,.T.)
						TRBSE1->TR_OK			:= __cMarca
						TRBSE1->TR_CLIENTE	:= SE1->E1_CLIENTE
						TRBSE1->TR_LOJA		:= SE1->E1_LOJA
						TRBSE1->TR_PREFIXO	:= SE1->E1_PREFIXO
						TRBSE1->TR_NUM			:= SE1->E1_NUM
						TRBSE1->TR_PARCELA	:= SE1->E1_PARCELA
						TRBSE1->TR_TIPO		:= SE1->E1_TIPO
						TRBSE1->TR_VALOR		:= SE1->E1_VALOR
						TRBSE1->TR_EMISSAO	:= SE1->E1_EMISSAO
						TRBSE1->TR_VENCTO		:= SE1->E1_VENCTO
						TRBSE1->TR_VENCREA	:= SE1->E1_VENCREA
						TRBSE1->TR_TPREC		:= "2" //Titulo Gerado 
						MsUnlock()
					Next
					// Elimina os titulos provisorios do cliente em questao
					F045GRVSUB(@aProvis)
				END TRANSACTION
			Endif
			If LMsErroAuto .or. lLast
				Exit
			Endif
			TRBSE1->(dbGoto(nRecTRBSE1))
		Enddo	
		If LMsErroAuto
			Exit
		Endif
		//Recarrego as perguntas desta rotina, descarregadas pela rotina automatica
		pergunte("FINA45",.F.)		
		//Relatorio
		If mv_par03 == 1 
			Fr045Rel()
		Endif
		Exit
	Else
		Exit
	Endif
Enddo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF045GRVSUBบAutor  ณRicardo Farinelli   บ Data ณ  12/19/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a eliminacao dos titulos provisorios gerados anteriorบฑฑ
ฑฑบ          ณmente, pois os mesmos ja foram substituidos                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSubstituicao de Titulos Automatica                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F045GRVSUB(aVetor)
Local n := 0

DbselectArea("SE1")
lMsErroAuto := .F. // variavel interna da rotina automatica	   	
For n := 1 to len(aVetor)
	MSExecAuto({|x,y| FINA040(x,y)},aVetor[n],5)
	If LMsErroAuto
		Help(" ",1,"EXCPROV",,aVetor[n,1,2]+"-"+aVetor[n,2,2]+"/"+aVetor[n,3,2]+"-"+aVetor[n,4,2],3,1) // Erro na Exclusao do Titulo do Contas a Receber
		DisarmTransaction()
		Break
	Endif
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFina045Inverte    ณRicardo Farinelli   บ Data ณ  01/04/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte e grava a marcacao na markBrowse                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fina045                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fina045Inverte(oMark)

Local nReg := SA1TRB->(Recno())
dbSelectArea("SA1TRB")
dbGoTop()
While !Eof()
	RecLock("SA1TRB")
	IF A1_OK == __cMarca
		SA1TRB->A1_OK := "  "
	Else
		SA1TRB->A1_OK := __cMarca
	Endif
	dbSkip()
Enddo
SA1TRB->(dbGoto(nReg))
oMark:oBrowse:Refresh(.t.)

Return Nil

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณChkField  บAutor  ณRicardo Farinelli   บ Data ณ  01/09/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica a existencia do campo A1_TIPPER e dos parametros   บฑฑ
ฑฑบ          ณMV_TIPPER e MV_NATPER para compatibilizar versoes anterioresบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA045                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ChkField()
Local lRet  		:=.T.

Dbselectarea("SX3")
Dbsetorder(2)
If !Dbseek("A1_TIPPER")
	MsgStop(STR0021+Chr(13)+Chr(10)+; //"Favor criar o campo A1_TIPPER do tipo Caracter, com tamanho de 2 em sua tabela de Clientes(SA1)."
	STR0022+Chr(13)+Chr(10)+; //"para que esta rotina possa ser executada."
	STR0023)  //"Para isso, vแ ao m๓dulo configurador e processa a inclusao do campo."
	lRet := .F.
Endif

dbSelectArea("SX6")
dbSetOrder(1)		//X6_FIL+X6_VAR
dbGoTop()
If !dbSeek(xFilial("SX6") + "MV_TIPPER")
	If !dbSeek(Space(Len(cFilAnt)) + "MV_TIPPER")
		lRet := .F.
	MsgStop(STR0024) //"Favor incluir o parametro MV_TIPPER do tipo caracter no configurador."
	EndIf
EndIf

If Empty(SuperGetMV("MV_TIPPER"))
	lRet := .F.
	MsgStop(STR0060)		//"O parโmetro MV_TIPPER estแ sem conte๚do."  
EndIf

If !dbSeek(xFilial("SX6") + "MV_NATPER")
	If !dbSeek(Space(Len(cFilAnt)) + "MV_NATPER")
	lRet := .F.
		MsgStop(STR0025)		//"Favor incluir o parametro MV_NATPER do tipo caracter no configurador e colocar o seu conteudo entre aspas."
	EndIf
EndIf

If Empty(SuperGetMV("MV_NATPER"))
	lRet := .F.
	MsgStop(STR0061)		//"O parโmetro MV_NATPER estแ sem conte๚do."
EndIf 

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  บA045Inverte ณMauricio Pequim Jr.       บ Data บ 04/03/01    บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInverte e grava a marcacao na markBrowse - TRBSE1           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Fina045                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A045Inverte()

Local nReg := TRBSE1->(Recno())
dbSelectArea("TRBSE1")
dbGoTop()
While !Eof()
	RecLock("TRBSE1")
	IF TRBSE1->TR_OK == __cMarca
		TRBSE1->TR_OK := "  "
	Else
		TRBSE1->TR_OK := __cMarca
	Endif
	dbSkip()
Enddo
TRBSE1->(dbGoto(nReg))

Return Nil


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณFa045Pesq ณ Autor ณ Mauricio Pequim Jr	  ณ Data ณ04.03.02  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ tela de pesquisa - WINDOWS 										  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 																  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fa045Pesq(oMark)

Local cCampo := Space(25)

DEFINE MSDIALOG oDlgb FROM	69,70 TO 160,331 TITLE STR0044 PIXEL   //"Pesquisar"
@ 1, 2 TO 22, 128 OF oDlgb  PIXEL
@ 7, 60	MSGET cCampo Picture "@!" SIZE 54, 10 OF oDlgb PIXEL MESSAGE STR0045 //"Cliente+Loja+Prefixo+Numero+Parcela+Tipo"
@ 8, 9 SAY STR0046 SIZE 54, 7 OF oDlgb PIXEL  //"Pesquisa"
DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (nOpca:=1,Fa045Acha(cCampo,oMark),;
								oDlgb:End(),nOpca:=0) OF oDlgb
DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION (oDlgb:End()) OF oDlgb
ACTIVATE MSDIALOG oDlgb
Return

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณFa045Acha ณ Autor ณ Mauricio Pequim Jr	  ณ Data ณ04.03.02  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao que realiza a pesquisa - WINDOWS						  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ Generico 																  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Fa045Acha(cCampo,oMark)

dbSelectArea("TRBSE1")
dbSeek(cCampo,.T.)
oMark:oBrowse:Refresh(.T.)

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Fr045Rel         ณ Mauricio Pequim       ณ Data ณ 04.03.02 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Impressao do relatorio analitico para conferencia          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ Fr045Rel()		 														  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA045				                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Fr045Rel()

Local cDesc1	:= STR0047 //"Este relatorio ir  demonstrar os titulos que foram utilizados para "
Local cDesc2	:= STR0048 //"para a montagem da negociacao bem como os titulos gerados por ela"
Local cDesc3	:= ""
Local wNrel
Local Tamanho	:= "G"
Local CbCont	:= 0
Local CbTxt		:= Space(10)
Local cString	:= "TRBSE1"
Local nColPrefixo	:= 1
Local nColNumero	:= 10
Local nColParcela	:= 21
Local nColTipo		:= 27
Local nColEmissao	:= 33
Local nColVencto	:= 45
Local nColVencRea	:= 57
Local nColValor	:= 69
Local nSubValor := 0
Local nTotValorS := 0
Local nTotValorG := 0
Local nTime := 1

Private Li			:= 80
Private M_pag		:= 1
Private Titulo		:= STR0049 //"Resultado Analitico para a conferencia - Negociacao CR"
Private cabec1		:= ""
Private cabec2		:= ""
Private aReturn	:= {STR0050, 1, STR0051, 2, 2, 1, "",1 } //### //"Zebrado"###"Administracao"
Private nomeprog	:= "FINA045"
Private nLastKey	:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "FR045Rel"
wnrel := SetPrint(cString,wNrel,,titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho,"",.F.)
If nLastKey == 27
	Return(Nil)
EndIf

SetDefault(aReturn,cString)
If nLastKey == 27
	Return(Nil)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Considerar filiais                                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Cabec1 := STR0052 //"Prefixo  Numero  Parc  Tipo  Emissao     Vencimento  Venc Real           Valor"
Cabec2 := ""
		  //"Prefixo  Numero    Parc  Tipo   Emissao     Vencimento  Venc Real           Valor"
		  // 123      123456789  123   123   99/99/9999  99/99/9999  99/99/9999  99,999,999.99
		  // 123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        //          10        20        30        40        50        60        70        80        90

dbSelectArea("TRBSE1")
dbGoTop()
While !Eof()
	cCliente := TRBSE1->(TR_CLIENTE+TR_LOJA)
	nTime := 1
	While !Eof() .and. TRBSE1->(TR_CLIENTE+TR_LOJA)== cCliente
		If Li >= 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
			Li := Prow()+1
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Imprime os titulos que geraram a negociacao                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While !Eof() .and. TRBSE1->(TR_CLIENTE+TR_LOJA)== cCliente .and. TRBSE1->TR_TPREC == "1"
			If Li >= 58
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
				Li := Prow()+1
			EndIf
			If nTime == 1
				@Li,00	PSAY STR0026  //"Cliente"
				@Li,11	PSAY TR_CLIENTE+"-"+TR_LOJA
				Li+=2
				nTime ++
			Endif
			If TR_OK = __cMarca
				@Li,nColPrefixo	PSAY TR_PREFIXO
				@Li,nColNumero		PSAY TR_NUM
				@Li,nColParcela	PSAY TR_PARCELA
				@Li,nColTipo		PSAY TR_TIPO
				@Li,nColEmissao	PSAY TR_EMISSAO
				@Li,nColVencto		PSAY TR_VENCTO			
				@Li,nColVencRea	PSAY TR_VENCREA			
				@Li,nColValor		PSAY TR_VALOR		Picture "@e 99,999,999.99"
   	
				nSubValor		+= TR_VALOR
				Li++
			Endif
			TRBSE1->(dbSkip())
		Enddo		
		If Li >= 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
			Li := Prow()+1
		EndIf
		@Li,000					PSAY STR0053 //"Sub-Total - Titulos Substituidos"
		@Li,nColValor			PSAY nSubValor		Picture "@e 99,999,999.99"

      Li+=2
		nTotValorS	+= nSubValor
		nSubValor	:= 0

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Imprime os titulos que foram gerados pela negociacao         ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		While !Eof() .and. TRBSE1->(TR_CLIENTE+TR_LOJA)== cCliente .and. TRBSE1->TR_TPREC == "2"
			If Li >= 58
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
				Li := Prow()+1
			EndIf
			If TR_OK = __cMarca
				@Li,nColPrefixo	PSAY TR_PREFIXO
				@Li,nColNumero		PSAY TR_NUM
				@Li,nColParcela	PSAY TR_PARCELA
				@Li,nColTipo		PSAY TR_TIPO
				@Li,nColEmissao	PSAY TR_EMISSAO
				@Li,nColVencto		PSAY TR_VENCTO			
				@Li,nColVencRea	PSAY TR_VENCREA			
				@Li,nColValor		PSAY TR_VALOR		Picture "@e 99,999,999.99"

				nSubValor		+= TR_VALOR
				Li++
			Endif
			TRBSE1->(dbSkip())
		Enddo		
		If Li >= 58
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
			Li := Prow()+1
		EndIf
		@Li,000					PSAY STR0054 //"Sub-Total - Titulos Gerados"
		@Li,nColValor			PSAY nSubValor		Picture "@e 99,999,999.99"
      Li++
		@Li,000 	PSAY __PrtThinLine()
      Li+=2
		nTotValorG	+= nSubValor
		nSubValor	:= 0
	Enddo
Enddo
If Li >= 58
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,Iif(aReturn[4]==1,15,18))
	Li := Prow()+1
EndIf
@Li,000					PSAY STR0055 //"TOTAL GERAL - Titulos Substituidos"
@Li,nColValor			PSAY nTotValorS	Picture "@e 99,999,999.99"
Li++
@Li,000					PSAY STR0056 //"TOTAL GERAL - Titulos Gerados"
@Li,nColValor			PSAY nTotValorG	Picture "@e 99,999,999.99"

Roda(CbCont,CbTxt,Tamanho)

If aReturn[5] = 1
	Set Printer To
	DbCommitAll()
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return(Nil)
             
/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณFinA045T   ณ Autor ณ Marcelo Celi Marques ณ Data ณ 04.04.08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Chamada semi-automatica utilizado pelo gestor financeiro   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ FINA045                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FINA045T()	

	cRotinaExec := "FINA045"
	ReCreateBrow("SE1",FinWindow)      	
	FinA045()
	ReCreateBrow("SE1",FinWindow)      	

	dbSelectArea("SE1")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.
