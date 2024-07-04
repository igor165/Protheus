#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

Static lautoSt := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA821
Rotina de separação de quebra de guias
Isso vai checar umas regras e criar uma nova guia a aprtir de determinadas participações de outra.
é tipo a Meiose, mas com guias e não células.
@author  Oscar
@version P12
@since   30/07/2020
/*/
//------------------------------------------------------------------- 
function PLSA821(lTela, lAuto)
Local aRetBD7 := {}
Local aAreaBCI	:= BCI->(getArea())
Local lUnimed := GetNewPar("MV_PLSUNI", "0") == "1"
Local lRegraAtv := GetNewPar("MV_PL7RDA", .F.)
Local lGo	:= PLsAliasEx("B6O") .AND. lUnimed .AND. !lRegraAtv
Local lOk := .F.
Local lProcessado := .F.

Default lTela := .T.
Default lAuto := .F.

lautoSt := lauto

If lGo .OR. lAuto
	dbselectArea("B6O")

	If BCI->BCI_TIPGUI $ '05/06' .AND. lUnimed
		aRetBD7 := PLS821Seek(BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
		lProcessado := aRetBD7[1]
		PLS821Proc(aRetBD7, BCI->BCI_CODOPE, BCI->BCI_CODLDP, BCI->BCI_CODPEG)
		If lTela
			If lProcessado
				If !lAuto
					MsgInfo("Separação do PEG concluída")
      		        lOk := .T.
				endif
			elseif !lAuto
				MsgInfo("Não houve alterações")
			endIf
        elseIf lProcessado
            lOk := .T.
		endIf
		
	elseif BCI->BCI_TIPGUI $ '05/06' .AND. !lUnimed
		If lTela
			MsgInfo('Funcionalidade não habilitada para a Operadora de Saúde')
		endIf
	else
		If lTela
			MsgInfo("opção disponível somente para protocolos de Guia de Resumo de Internação e Guia de Honorários")
		endIf
	endIf
	restarea(aAreaBCI)
endIf
return lOk

//Função para retornar se um profissional de saúde está vinculado à um cadastro de RDA (BAU)
function PLS821Seek( cCodOpe, cCodLdp, ccodPEG)

Local aRet 	:= {}
Local cSql := ""
Local nPos  := 0

Default cCodOpe := PLSINTPAD()
Default cCodLdp := " "
default ccodPEG := " "

    cSql += " Select BD7.R_E_C_N_O_ D7REC, BD6.R_E_C_N_O_ D6REC, BAU.R_E_C_N_O_ AUREC, BB82.R_E_C_N_O_ B8REC, "
    cSql += " BD7.BD7_NUMERO NUMERO "
    cSql += " from " + RetsqlName("BAU") + " BAU "
	
    cSql += " Inner Join " 
	cSql += retsqlName("BB0") + " BB0 "
	csql += " On "
	csql += " BB0_FILIAL = '" + xfilial("BB0") + "' AND "// BAU_FILIAL AND
	cSql += " BB0_CODIGO = BAU_CODBB0 AND "
	cSql += " BB0.D_E_L_E_T_ = ' ' "

	csql += " Inner Join "
	csql += RetSqlName("BD7") + " BD7 "
	cSql += " On "
	cSql += " BD7_FILIAL = '" + xfilial("BD7") + "' AND "
	cSql += " BD7_CODOPE = '" + cCodOpe + "' AND "
	csql += " BD7_CODLDP = '" + cCodLdp + "' AND "
	cSql += " BD7_CODPEG = '" + cCodPEG + "' AND "
	cSql += " BD7_FASE   = '1' AND "
	cSql += " BD7_CDPFPR = BB0_CODIGO AND "
	cSql += " BD7_CDPFPR <> ' ' AND "
	csql += " BD7_CODUNM NOT IN " + formatIn("COP|COR|UCO|FIL|DOP|CRR|INC|TCR|VDI|VMD|VMT|VTX", "|") + " AND "
	cSql += " BD7_BLOPAG <> '1' AND "
	cSql += " BD7.D_E_L_E_T_ =  '  ' "

	csql += " Inner Join "
	csql += RetSqlName("BD6") + " BD6 "
	cSql += " On "
	cSql += " BD6_FILIAL = '" + xfilial("BD6") + "' AND "
	cSql += " BD6_CODOPE = BD7_CODOPE AND "
	csql += " BD6_CODLDP = BD7_CODLDP AND "
	cSql += " BD6_CODPEG = BD7_CODPEG AND "
    cSql += " BD6_NUMERO = BD7_NUMERO AND "
    cSql += " BD6_ORIMOV = BD7_ORIMOV AND "
    cSql += " BD6_SEQUEN = BD7_SEQUEN AND "
    cSql += " BD6_PAGRDA <> '1' AND "
	cSql += " BD6.D_E_L_E_T_ =  '  ' "

	cSql += " Left Join "
	cSql += RetSqlName("B6O") + " B6O "
	cSql += " On "
	cSql += " B6O_FILIAL = '" + xfilial("B6O") + "' AND "
	cSql += " B6O_OPEORI = BD6_OPEORI AND "
	cSql += " B6O_LDPORI = BD6_CODLDP AND "
	cSql += " B6O_PEGORI = BD6_CODPEG AND "
	cSql += " B6O_NUMORI = BD6_NUMERO AND "
	cSql += " B6O.D_E_L_E_T_ = ' ' "

    csql += " Inner Join " + retsqlname("BB8") + " BB81 "
    cSql += " On "
    cSql += " BB81.BB8_FILIAL = '" + xFilial("BB8") + "' AND "
    cSql += " BB81.BB8_CODIGO = BD7_CODRDA AND "
    cSql += " BB81.BB8_CODLOC = BD7_CODLOC AND "
    cSql += " BB81.BB8_CNES <> ' ' AND "
    cSql += " BB81.D_E_L_E_T_ = ' ' "

    cSql += " Inner Join " + retSqlName("BB8") + " BB82 "
    cSql += " On "
    cSql += " BB82.BB8_FILIAL = '" + xFilial("BB8") + "' AND "
    cSql += " BB82.BB8_CODIGO = BAU_CODIGO AND "
    cSql += " BB82.BB8_CNES = BB81.BB8_CNES AND "
    cSql += " BB82.D_E_L_E_T_ = ' ' "

	cSql += " Where "
	cSql += " B6O_NUMORI IS NULL AND "
	cSql += " BAU_FILIAL = '" + Xfilial("BAU") + "' AND "
	cSql += " BAU_CODIGO <> BD7_CODRDA AND "
	cSql += " BAU_COPCRE = '1' AND "
    cSql += " BAU_TPCALC <> '3' AND "
	cSql += " BAU.D_E_L_E_T_ = ' ' "
	
	cSql += " Order By BD6.R_E_C_N_O_ "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"BB0xBAU",.F.,.T.)
	
	while !(BB0xBAU->(EoF()))

        If !(empTy(aret))
            nPos := aScan(aret, {|x| x[1] == BB0xBAU->D6REC })
        endIf

        If nPos == 0
            aadd(aRet, {BB0xBAU->D6REC, {BB0xBAU->D7REC}, BB0xBAU->NUMERO, BB0xBAU->B8REC})
        else
            aadd(aRet[nPos][2], BB0xBAU->D7REC)
        endIf

		BB0xBAU->(dbskip())
	endDo
	BB0xBAU->(dbclosearea())
	If !(empty(aRet))
		aSort(aRet,,,{|x,y| x[3] < y[3]})
	endIf

return {!(Empty(aRet)), aRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS821Proc
Cria guias novas
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function PLS821Proc(aRet, cCodOpe, cCodLdp, ccodPEG)

Local aDados := {}
Local aItens := {}
local nI 	 := 1
Local cNumAnt := ""
Local cMatric := ""
Local cTipo	  := ""
Local nK	:= 1
Local nRecant := 0
Local aRecTran := {}
Local nJ	:= 1
Local aPart	:= {}
Local cPart := ""
Local arecBlock := {}
Local nRecOrig	:= 0
Local cAliaOrig	:= ""
Local nRecDesti	:= 0
Local lcodesp	:= .T.

If aRet[1]

	BKC->(dbsetOrder(1))
	BAX->(dbsetOrder(1))

	For nI := 1 To Len(aRet[2])

		If cNumAnt <> aRet[2][nI][3]
			aDados := {}
			aItens := {}
			aRecTran := {}
			nRecAnt	:= 0
			cNumAnt := aRet[2][nI][3]
			nRecOrig	:= 0
			cAliaOrig	:= ""
			lcodesp := .T.
			BB8->(DbGoTo(aRet[2][nI][4]))
			AaDd( aDados, {"ORI821", .T. } )
			AaDd( aDados, {"OPEMOV", cCodOpe } )
			AaDd( aDados, {"CODRDA", BB8->BB8_CODIGO } )
			AaDd( aDados, {"CODLOC", BB8->BB8_CODLOC } )
			If !(empty(BCI->BCI_ARQUIV))
				AaDd( aDados, {"ARQIMP", BCI->BCI_ARQUIV } )
			endIf
		else
			loop
		endIf

		If BCI->BCI_TIPGUI == "05"
			
			BE4->(dbSetOrder(1))
			BE4->(Msseek(xfilial("BE4") + cCodOpe + cCodLdp + cCodPeg + aRet[2][nI][3]))
			If empty(BE4->BE4_MATANT)
				cMatric := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
				cTipo := "1"
			else
				cMatric := BE4->BE4_MATANT
				ctipo := "2"
			endif

			nRecOrig	:= BE4->(recno())
			cAliaOrig	:= "BE4"

			PLSDADUSR(cMatric,cTipo,.f.,BE4->BE4_DATPRO)
			aDadUsr := PLSGETUSR()

			AaDd( aDados, {"USUARIO", cMatric } )
			AaDd( aDados, {"CDPFSO" , BE4->BE4_CDPFSO } )
			AaDd( aDados, {"NUMSOL" , BE4->BE4_SENHA } )
			AaDd( aDados, {"LOTGUI" , BE4->BE4_LOTGUI } )
			AaDd( aDados, {"PADCON" , BE4->BE4_PADCON } )
			AaDd( aDados, {"CIDPRI" , BE4->BE4_CID } )
			//AaDd( aDados, {"CODESP" , BE4->BE4_CODESP } )
			AaDd( aDados, {"NUMIMP" , BE4->BE4_NUMIMP } )
			AaDd( aDados, {"NOMUSR" , BE4->BE4_NOMUSR } )
			AaDd( aDados, {"TIPFAT" , BE4->BE4_TIPFAT } )
			AaDd( aDados, {"TIPGUI" , "06" } )
			AaDd( aDados, {"TIPINT" , BE4->BE4_TIPINT } )
			AaDd( aDados, {"TPEVEN" , BE4->BE4_GRPINT } )
			AaDd( aDados, {"INDACI" , BE4->BE4_INDACI } )
			AaDd( aDados, {"UNDDOE" , BE4->BE4_UTPDOE } )
			AaDd( aDados, {"TMPDOE" , BE4->BE4_TPODOE } )
			AaDd( aDados, {"TIPDOE" , BE4->BE4_TIPDOE } )
			AaDd( aDados, {"INDCLI" , BE4->BE4_INDCLI } )
			AaDd( aDados, {"TIPADM" , BE4->BE4_TIPADM } )
			AaDd( aDados, {"REGINT" , BE4->BE4_REGINT } )
			AaDd( aDados, {"HORIND" , .T. } )
			AaDd( aDados, {"RPC"    , .F. } )
			AaDd( aDados, {"DATPRO" , BE4->BE4_DATPRO } )
			AaDd( aDados, {"HORAPRO", BE4->BE4_HORPRO } )
			AaDd( aDados, {"MSG01"  , BE4->BE4_MSG01 } )
			AaDd( aDados, {"MSG02"  , BE4->BE4_MSG02 } )
			AaDd( aDados, {"CODLDP" , BE4->BE4_CODLDP } )
			AaDd( aDados, {"ESPSOL" , BE4->BE4_ESPSOL } )
			AaDd( aDados, {"TIPCON" , BE4->BE4_TIPCON } )
			AaDd( aDados, {"DATACA" , BE4->BE4_DTDIGI } )
			AaDd( aDados, {"ESPEXE" , BE4->BE4_ESPEXE } )
			AaDd( aDados, {"ATENRN" , BE4->BE4_ATERNA } )
			AaDd( aDados, {"FASE"   , "1" } )
			AaDd( aDados, {"GUIORI" , BE4->BE4_GUIORI } )

			//AaDd( aDados, {"TAG" , Valor } )
		else
			BD5->(dbSetOrder(1))
			BD5->(Msseek(xfilial("BD5") + cCodOpe + cCodLdp + cCodPeg + aRet[2][nI][3]))
			If empty(BD5->BD5_MATANT)
				cMatric := BD5->(BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO)
				cTipo := "1"
			else
				cMatric := BD5->BD5_MATANT
				ctipo := "2"
			endif

			nRecOrig	:= BD5->(recno())
			cAliaOrig	:= "BD5"

			PLSDADUSR(cMatric,cTipo,.f.,BD5->BD5_DATPRO)
			aDadUsr := PLSGETUSR()

			AaDd( aDados, {"USUARIO", cMatric } )
			AaDd( aDados, {"TIPSAI" , BD5->BD5_TIPSAI } )
			AaDd( aDados, {"CDPFSO" , BD5->BD5_CDPFSO } )
			AaDd( aDados, {"NUMLIB" , If( !(empty(BD5->BD5_NRAOPE)), BD5->BD5_NRAOPE, BD5->BD5_SENHA) } )
			AaDd( aDados, {"PADCON" , BD5->BD5_PADCON } )
			AaDd( aDados, {"CIDPRI" , BD5->BD5_CID } )
			//AaDd( aDados, {"CODESP" , BD5->BD5_CODESP } )
			AaDd( aDados, {"NUMIMP" , BD5->BD5_NUMIMP } )
			AaDd( aDados, {"NOMUSR" , BD5->BD5_NOMUSR } )
			AaDd( aDados, {"TIPFAT" , BD5->BD5_TIPFAT } )
			AaDd( aDados, {"TIPGUI" , "06" } )
			AaDd( aDados, {"TIPINT" , BD5->BD5_TIPINT } )
			AaDd( aDados, {"TPEVEN" , BD5->BD5_GRPINT } )
			AaDd( aDados, {"INDACI" , BD5->BD5_INDACI } )
			AaDd( aDados, {"UNDDOE" , BD5->BD5_UTPDOE } )
			AaDd( aDados, {"TMPDOE" , BD5->BD5_TPODOE } )
			AaDd( aDados, {"TIPDOE" , BD5->BD5_TIPDOE } )
			AaDd( aDados, {"TIPO"   , "1" } )
			AaDd( aDados, {"INDCLI" , BD5->BD5_INDCLI + BD5->BD5_INDCL2 } )
			AaDd( aDados, {"TIPADM" , BD5->BD5_TIPADM } )
			AaDd( aDados, {"REGINT" , BD5->BD5_REGINT } )
			AaDd( aDados, {"HORIND" , .T. } )
			AaDd( aDados, {"RPC"    , .F. } )
			AaDd( aDados, {"DATPRO" , BD5->BD5_DATPRO } )
			AaDd( aDados, {"HORAPRO", BD5->BD5_HORPRO } )
			AaDd( aDados, {"TIPATE" , BD5->BD5_TIPATE } )
			AaDd( aDados, {"CODLDP" , BD5->BD5_CODLDP } )
			AaDd( aDados, {"ESPSOL" , BD5->BD5_ESPSOL } )
			AaDd( aDados, {"TIPCON" , BD5->BD5_TIPCON } )
			AaDd( aDados, {"DATACA" , BD5->BD5_DTDIGI } )
			AaDd( aDados, {"ESPEXE" , BD5->BD5_ESPEXE } )
			AaDd( aDados, {"ATENRN" , BD5->BD5_ATERNA } )
			AaDd( aDados, {"FASE"   , "1" } )
			AaDd( aDados, {"GUIORI" , BD5->BD5_GUIORI } )
			AaDd( aDados, {"GUIPRI" , BD5->BD5_GUIPRI } )
			AaDd( aDados, {"TIPATO" , BD5->BD5_TIPATO } )

			//AaDd( aDados, {"TAG" , Valor } )
		endIf

		For nK	:= nI To Len(aRet[2])
			If aRet[2][nK][3] <> cNumAnt
				exit
			endIf
			
			If nRecant <> aRet[2][nK][1] .AND. aScan(aRecTran, aRet[2][nK][1]) == 0
				nRecant := aRet[2][nK][1]
				BD6->(dbGoto(nRecant))
				aPart := {}
			else
				Loop
			endIf

			If BR8->( MsSeek(xFilial("BR8")+BD6->BD6_CODPAD+BD6->BD6_CODPRO) ) .And. BR8->BR8_TPPROC == "6"
				Loop
			endIf
			aadd(aRecTran, nRecant)

			aadd(aItens,{})
			aadd(aItens[Len(aItens)], {"RPC", .F.})
			aadd(aItens[Len(aItens)], {"SEQMOV", BD6->BD6_SEQUEN})
			aadd(aItens[Len(aItens)], {"CODPAD", BD6->BD6_CODPAD})
			aadd(aItens[Len(aItens)], {"CODPRO", BD6->BD6_CODPRO})
			aadd(aItens[Len(aItens)], {"DESPRO", BD6->BD6_DESPRO})
			aadd(aItens[Len(aItens)], {"QTD"   , BD6->BD6_QTDPRO})
			aadd(aItens[Len(aItens)], {"HORINI", BD6->BD6_HORPRO})
			aadd(aItens[Len(aItens)], {"HORFIM", BD6->BD6_HORFIM})
			aadd(aItens[Len(aItens)], {"DATPRO", BD6->BD6_DATPRO})
			aadd(aItens[Len(aItens)], {"SLVPAD", BD6->BD6_CODPAD})
			aadd(aItens[Len(aItens)], {"SLVPRO", BD6->BD6_CODPRO})
			for nJ := 1 To Len(aRet[2][nK][2])

				BD7->(dbGoTo(aRet[2][nK][2][nJ]))
				cPart := ""
				If lcodesp
					If BAX->(MsSeek(xfilial("BAX")+BB8->BB8_CODIGO+PLSINTPAD()+BB8->BB8_CODLOC+BD7->BD7_CODESP))
						AaDd( aDados, {"CODESP" , BD7->BD7_CODESP } )
						lcodesp := .F.
					endIf
				endIf
				aadd(arecBlock, aRet[2][nK][2][nJ])

				If !(Empty(BD7->BD7_CODTPA))
					cPart := BD7->BD7_CODTPA
				else
					If BKC->(MsSeek(xfilial("BKC")+BD7->BD7_CODUNM+BD7->BD7_CODOPE))
						cPart := Alltrim(BKC->BKC_CODPAR)
					else
						cPart := GetNewPar("MV_PLSNAPL","O")
					endIf
				endIf

				aadd(aPart ,{cPart ;
						   ,BB8->BB8_CODIGO;
						   ,"";
						   ,BD7->BD7_REGPRE;
						   ,BD7->BD7_SIGLA;
						   ,BD7->BD7_ESTPRE;
						   ,BD7->BD7_NOMPRE;
						   ,.T.;
						   ,BB8->BB8_CODIGO;
						   ,BD7->BD7_CODESP;
						   ,PlRetUnp( cPart )} )

			next
			If !(empty(aPart))
				aadd(aItens[Len(aItens)], {"ATPPAR", aPart})
			endIf
			//Se o lCodesp chegou .T. aqui, é que só tem especialidade inválida, então usa a primeira que achar no BAX
			If lCodEsp
				If BAX->(MsSeek(xfilial("BAX")+BB8->BB8_CODIGO+PLSINTPAD()+BB8->BB8_CODLOC))
					AaDd( aDados, {"CODESP" , BAX->BAX_CODESP } )
					lcodesp := .F.
				endIf
			endIf
		Next

		Begin transaction
			PLSXAUTP(aDados,aItens,,@nRecDesti)
			PLS821BLOQ(arecBlock)
			PLS821Path(nRecDesti,nRecOrig,cAliaOrig)
		End Transaction
	next
	
Endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS821BLOQ
Bloqueia participações originais
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function PLS821BLOQ(arecBlock)

Local nI := 0
Local cMotblo := GetNewPar("MV_PLQGMB", "X")
Local cDesblo := "Separação de guia"

for nI := 1 to Len(arecBlock)
	BD7->(dbgoTo(arecBlock[1]))
	BD7->(reclock("BD7",.F.))
		BD7->BD7_BLOPAG := "1"
		BD7->BD7_MOTBLO := cMotblo
		BD7->BD7_DESBLO := cDesblo
	BD7->(MsUnlock())
next

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS821Path
Grava rastreio
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function PLS821Path(nRecDesti,nRecOrig,cAliaOrig)

Local achvOrigem := {}
Local achvDestin := {}
Local l1 := .F.
Local l2 := .F.

If cAliaOrig == "BE4"
	BE4->(dbgoTo(nRecOrig))
	aadd(achvOrigem, BE4->BE4_CODOPE)
	aadd(achvOrigem, BE4->BE4_CODLDP)
	aadd(achvOrigem, BE4->BE4_CODPEG)
	aadd(achvOrigem, BE4->BE4_NUMERO)
else
	BD5->(dbGoto(nRecOrig))
	aadd(achvOrigem, BD5->BD5_CODOPE)
	aadd(achvOrigem, BD5->BD5_CODLDP)
	aadd(achvOrigem, BD5->BD5_CODPEG)
	aadd(achvOrigem, BD5->BD5_NUMERO)
endif

BD5->(dbGoTo(nRecDesti))
aadd(achvDestin, BD5->BD5_CODOPE)
aadd(achvDestin, BD5->BD5_CODLDP)
aadd(achvDestin, BD5->BD5_CODPEG)
aadd(achvDestin, BD5->BD5_NUMERO)

//Gravar a B6O, não oficializar a tabela até definir que isso vai pro padrão
B6O->(dbsetOrder(1))
l1 := B6O->(MsSeek(xfilial("B6O")+achvOrigem[1]+achvOrigem[2]+achvOrigem[3]+achvOrigem[4]))
B6O->(dbsetOrder(2))
l2:= B6O->(MsSeek(xfilial("B6O")+achvDestin[1]+achvDestin[2]+achvDestin[3]+achvDestin[4]))

If !l1 .OR. !l2
	B6O->(RecLock("B6O",.T.))
		B6O->B6O_FILIAL := xfilial("B6O")
		B6O->B6O_OPEORI := achvOrigem[1]
		B6O->B6O_LDPORI := achvOrigem[2]
		B6O->B6O_PEGORI := achvOrigem[3]
		B6O->B6O_NUMORI := achvOrigem[4]
		B6O->B6O_OPEDES := achvDestin[1]
		B6O->B6O_LDPDES := achvDestin[2]
		B6O->B6O_PEGDES := achvDestin[3]
		B6O->B6O_NUMDES := achvDestin[4]
	B6O->(MsUnLock())
endIf

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLchkQuebr
Verificação de permissão de cancelamento
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function PLchkQuebr(cCodOpe, cCodLdp, cCodPeg, cNumero)

Local lRet := .F.
Local l1 := .F.
Local l2 := .F.

Default cNumero := ""

B6O->(dbsetOrder(1))
l1 := B6O->(MsSeek(xfilial("B6O")+cCodOpe+cCodLdp+cCodPeg+cNumero))
B6O->(dbsetOrder(2))
l2 := B6O->(MsSeek(xfilial("B6O")+cCodOpe+cCodLdp+cCodPeg+cNumero))

lRet := !(l1 .OR. l2)

If !lRet
	MsgAlert("Esta guia não pode ser cancelada, pois a regra de separação de honorários foi aplicada")
endIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P821adFila
colocador de guia separada na fila
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function P821adFila(ccodPeg, ccodldp)
Local cSql := ""

csql += " Select distinct B6O_LDPDES, B6O_PEGDES From " + retSqlName("B6O") + " B6O "
cSql += " Where "
cSql += " B6O_FILIAL = '" + xFilial("B6O") + "' AND "
cSql += " B6O_OPEORI = '" + PLSINTPAD() + "' AND "
cSql += " B6O_LDPORI = '" + ccodldp + "' AND "
cSql += " B6O_PEGORI = '" + ccodPeg + "' AND "
cSql += " B6O.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"B6OxBXX",.F.,.T.)

while !(B6OxBXX->(EoF()))
	addFilaPLS(B6OxBXX->B6O_PEGDES, B6OxBXX->B6O_LDPDES, "06")
	B6OxBXX->(dbskip())
EndDo

B6OxBXX->(dbcloseArea())
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL821EXCXML
Verifica permissão e exclui guias separadas e exclui se puder
@author  Oscar
@version P12
@since   30/07/2020
/*/
//-------------------------------------------------------------------
function PL821EXCXML(cCodOpe, ccodldp, ccodPeg)
Local cSql := ""
Local aDadBCI := {}
Local lProcessa := .T.
Local nI := 1
Local lInicia := .F.

BCI->(dbsetOrder(1))
If BCI->(MsSeek(xfilial("BCI") + cCodOpe + ccodLdp + ccodPeg))
	PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
	lInicia := BCI->BCI_FASE == "1"
endIf

If lInicia
	cSql += " select distinct BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI.R_E_C_N_O_ RECBCI From "
	cSql += RetSqlName("BCI") + " BCI "
	cSql += " Inner Join " + RetSqlName("B6O") + " B6O "
	cSql += " On "
	cSql += " B6O.B6O_FILIAL = '" + xfilial("B6O") + "' AND "
	cSql += " B6O.B6O_OPEDES = BCI_CODOPE AND "
	cSql += " B6O.B6O_LDPDES = BCI_CODLDP AND "
	cSql += " B6O.B6O_PEGDES = BCI_CODPEG AND "
	cSql += " B6O.D_E_L_E_T_ = ' ' "
	cSql += " Inner Join " + retSqlName("B6O") + " B6O_ORI "
	cSql += " On "
	cSql += " B6O_ORI.B6O_FILIAL = '" + xFilial("B6O") + "' AND "
	cSql += " B6O_ORI.B6O_OPEORI = '" + cCodOpe + "' AND "
	cSql += " B6O_ORI.B6O_LDPORI = '" + cCodLdp + "' AND "
	cSql += " B6O_ORI.B6O_PEGORI = '" + cCodPeg + "' AND "
	cSql += " B6O_ORI.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",tcGenQry(,,cSql),"B6ORast",.F.,.T.)
	while !B6ORast->(EoF())
		BCI->(dbGoTo(B6ORast->RECBCI))
		PLSM190Pro(,,,,,,,,,,,.f.,.t.,BCI->(recno()))
		If BCI->BCI_FASE == "1"
			aadd(aDadBCI, B6ORast->BCI_CODOPE + B6ORast->BCI_CODLDP + B6ORast->BCI_CODPEG)
		else
			lProcessa := .F.
			MsgAlert("Há protocolos vinculados com fase diferente de DIGITACAO")
			aDadBCI := {}
			exit
		endIf
		B6ORast->(dbskip())
	EndDo
	B6ORast->(dbclosearea())

	If lProcessa
		B6O->(dbsetOrder(2))
		For nI := 1 to Len(aDadBCI)
			Begin transaction
				PLSDELMOVZ(aDadBCI[ni],"1",.T.)
				If B6O->(MsSeek(xfilial("B6O") + aDadBCI[ni] ))
					While !(B6O->(EoF())) .AND. aDadBCI[ni] == B6O->(B6O_OPEDES+B6O_LDPDES+B6O_PEGDES)
						B6O->(recLock("B6O", .F.))
							B6O->(DbDelete())
						B6O->(MsUnLock())
						B6O->(Dbskip())
					endDo
				endIf
			end transaction
		next
	endIf
endIf

return lProcessa
