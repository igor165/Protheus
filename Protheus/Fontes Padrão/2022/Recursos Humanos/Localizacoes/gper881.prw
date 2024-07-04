#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "GPER881.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma     ³ GPER881  º Autor ³ Ademar Fernandes   º Data ³ 07/07/2009   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao    ³ Imprime as verbas que compoe a Maior Remuneracao            º±±
±±º             ³ -SAC ou Indenizatoria                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso          ³ Microsiga Protheus 10 - TopConnect                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º             ³    ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador  ³ Data   ³PLANO/FNC       ³  Motivo da Alteracao              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAlceu Pereira³14/09/09³000000211832009 ³Alteracao realizada para considerarº±±
±±º				  ³		    ³                ³verbas de desconto.                º±±
±±ºRaquel Hager ³05/06/12³00000014107/2012³Correcao para impresso de cDesc1 e º±±
±±º				  ³		    ³          TFCDCC³cDesc2 corretamente traduzidas.    º±±
±±³             ³        ³                ³                                   ³±±
±±³Jonathan Glez³07/05/15³      PCREQ-4256³Se elimina funcion ValidPerg Cual  ³±±
±±³             ³        ³                ³realiza la modificacion a diccio-  ³±±
±±³             ³        ³                ³nario de datos(SX1) por motivo de  ³±±
±±³             ³        ³                ³adecuacion nuevaestructura de SXs  ³±±
±±³             ³        ³                ³para V12                           ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER881()

//³ Declaracao de Variaveis
Local cDesc1       := STR0020 // Este programa tem como objetivo imprimir relatorio
Local cDesc2       := STR0021 // de acordo com os parametros informados pelo usuario.
Local cDesc3       := STR0014 // Relatorio de Mayor Remuneracion
Local cPict        := ""
Local titulo       := STR0014// Relatorio de Mayor Remuneracion
Local nLin         := 80
Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd         := {}
Local cQuery       := ""
Local nTReg        := 0
Local cPerg        := "GPR881"
Local cData01      := ""
Local cData02      := ""

Private n1Mes       := 0
Private nArr1Mes    := 0
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "GPER881" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "GPER881" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SRD"
Private aDados  := {}
Private lDtRef  := .F.	//# Indica se a pesquisa nos acumulados sera por Data de Referencia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se sera utilizado o RD_DATPGT ou RD_DTREF                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RCA")
dbSetOrder(1)	//# RCA_FILIAL+RCA_MNEMON
lDtRef := dbSeek(xFilial("RCA")+"P_MAIORSAL      ",.F.)

dbSelectArea(cString)
dbSetOrder(1)

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

/*
	Array aReturn, preenchido pelo SetPrint
	[1] Reservado para Formulário
	[2] Reservado para Nº de Vias
	[3] Destinatário
	[4] Formato => 1-Comprimido 2-Normal
	[5] Mídia => 1-Disco 2-Impressora
	[6] Porta ou Arquivo 1-LPT1... 4-COM1...
	[7] Expressão do Filtro
	[8] Ordem a ser selecionada
	[9]..[10]..[n] Campos a Processar (se houver)
	cAlias - Alias do arquivo a ser impresso.
*/
SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia o processamento ...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If mv_par03 == 1	//# RV_MED13='S'
	If Month(mv_par04) <= 06
		cData01 := Str(Year(mv_par04),4)+"01"
	Else
		cData01 := Str(Year(mv_par04),4)+"07"
	EndIf
	cData02 := AnoMes(mv_par04)

Else				//# RV_INDEN='1' (Antigo RV_REMUNE='S')
	cData01 := AnoMes(Menos1Ano(mv_par04))
	cData02 := AnoMes(mv_par04)
EndIf

//# Guarda o Primeiro Mes a ser impresso
n1Mes := Val(SubStr(cData01,5,2))
nArr1Mes := n1Mes + 4	//# Mes 1 inicia na posicao 5 do array

fQrySRD(cData01,cData02)	//# Busca os movimentos do acumulado
fQrySRC(cData01,cData02)	//# Busca os movimentos do mes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime o relatorio ...                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aDados) > 0
	RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin) }, Titulo)
Else
	Aviso(STR0015,STR0016,{"OK"},3,FunDesc())
EndIf
Return



/******************************/
Static Function fQrySRD(cData01,cData02)

Local cAlias := "QSRD"

MsgRun(STR0013,"",{|| CursorWait(),ImpOK(),CursorArrow()})

cQuery := "SELECT * FROM "+RetSqlName("SRD")+" RD "
cQuery += "INNER JOIN "+RetSqlName("SRV")+" RV "
cQuery += "ON RV.D_E_L_E_T_=' ' AND RV_FILIAL='"+xFilial("SRV")+"' "
cQuery += "AND RV_COD=RD_PD "
If mv_par03 == 1
	cQuery += "AND RV_MED13='S' "
Else
	cQuery += "AND RV_INDEN='1' "
EndIf

cQuery += "WHERE RD.D_E_L_E_T_=' ' AND RD_FILIAL='"+xFilial("SRD")+"' "
cQuery += "AND RD_MAT>='"+mv_par01+"' "
cQuery += "AND RD_MAT<='"+mv_par02+"' "
cQuery += "AND RD_ROTEIR='LIQ' "

If !lDtRef .OR. (RCA->RCA_CONTEU == "1")
	cQuery += "AND SUBSTRING(RD_DATPGT,1,6)>='"+cData01+"' "
	cQuery += "AND SUBSTRING(RD_DATPGT,1,6)<='"+cData02+"' "
	cQuery += "ORDER BY RD_FILIAL,RD_MAT,RD_DATPGT,RD_PD,RD_SEQ "
Else
	cQuery += "AND SUBSTRING(RD_DTREF,1,6)>='"+cData01+"' "
	cQuery += "AND SUBSTRING(RD_DTREF,1,6)<='"+cData02+"' "
	cQuery += "ORDER BY RD_FILIAL,RD_MAT,RD_DTREF,RD_PD,RD_SEQ "
EndIf
cQuery := ChangeQuery(cQuery)

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

TCQUERY cQuery NEW ALIAS &cAlias
Count To nTReg	//# Conta os registros retornados
aEval( SRD->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAlias,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros
(cAlias)->(dbGotop())

If nTReg > 0
	Processa({|| RunProc1(nTReg, cAlias)}, STR0018, STR0017 )

	If Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	Endif
EndIf
Return



/******************************/
Static Function fQrySRC(cData01,cData02)

Local cAlias := "QSRC"

MsgRun(STR0013,"",{|| CursorWait(),ImpOK(),CursorArrow()})

cQuery := "SELECT * FROM "+RetSqlName("SRC")+" RC "
cQuery += "INNER JOIN "+RetSqlName("SRV")+" RV "
cQuery += "ON RV.D_E_L_E_T_=' ' AND RV_FILIAL='"+xFilial("SRV")+"' "
cQuery += "AND RV_COD=RC_PD "
If mv_par03 == 1
	cQuery += "AND RV_MED13='S' "
Else
	cQuery += "AND RV_INDEN='1' "
EndIf

cQuery += "WHERE RC.D_E_L_E_T_=' ' AND RC_FILIAL='"+xFilial("SRC")+"' "
cQuery += "AND RC_MAT>='"+mv_par01+"' "
cQuery += "AND RC_MAT<='"+mv_par02+"' "
cQuery += "AND RC_ROTEIR='LIQ' "

If !lDtRef .OR. (RCA->RCA_CONTEU == "1")
	cQuery += "AND SUBSTRING(RC_DATA,1,6)>='"+cData01+"' "
	cQuery += "AND SUBSTRING(RC_DATA,1,6)<='"+cData02+"' "
	cQuery += "ORDER BY RC_FILIAL,RC_MAT,RC_DATA,RC_PD,RC_SEQ "
Else
	cQuery += "AND SUBSTRING(RC_DTREF,1,6)>='"+cData01+"' "
	cQuery += "AND SUBSTRING(RC_DTREF,1,6)<='"+cData02+"' "
	cQuery += "ORDER BY RC_FILIAL,RC_MAT,RC_DTREF,RC_PD,RC_SEQ "
EndIf
cQuery := ChangeQuery(cQuery)

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif

TCQUERY cQuery NEW ALIAS &cAlias
Count To nTReg	//# Conta os registros retornados
aEval( SRC->(dbStruct()),{|x| IIF(x[2] != "C",TcSetField(cAlias,x[1],x[2],x[3],x[4]),Nil)} )	//# Corrige a forma das Datas e Numeros
(cAlias)->(dbGotop())

If nTReg > 0
	Processa({|| RunProc1(nTReg, cAlias)}, STR0018, STR0017 )

	If Select(cAlias) > 0
		(cAlias)->(dbCloseArea())
	Endif
EndIf
Return



/******************************/
Static Function RunProc1(nTReg, cAlias)

Local cMes := ""
Local cAno := ""
Local nPos := 0

If cAlias == "QSRC"
	cCpoMat := "QSRC->RC_MAT"
	cCpoPD  := "QSRC->RC_PD"
	cCpoPGT := "QSRC->RC_DATA"
	cCpoREF := "QSRC->RC_DTREF"
	cCpoVLR := "QSRC->RC_VALOR"
	cCpoVRB := "QSRC->RV_DESC"

ElseIf cAlias == "QSRD"
	cCpoMat := "QSRD->RD_MAT"
	cCpoPD  := "QSRD->RD_PD"
	cCpoPGT := "QSRD->RD_DATPGT"
	cCpoREF := "QSRD->RD_DTREF"
	cCpoVLR := "QSRD->RD_VALOR"
	cCpoVRB := "QSRD->RV_DESC"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua(nTReg)

While !EOF()

	IncProc( STR0018+&cCpoMat+"-"+&cCpoPD )

	If !lDtRef .OR. (RCA->RCA_CONTEU == "1")
		cMes := SubStr(DTOS(&cCpoPGT),5,2)
		cAno := SubStr(DTOS(&cCpoPGT),1,4)
	Else
		cMes := SubStr(DTOS(&cCpoREF),5,2)
		cAno := SubStr(DTOS(&cCpoREF),1,4)
	EndIf

	nPos := aScan(aDados, {|x| x[01]+x[02]==&cCpoMat+&cCpoPD })
	If nPos = 0
		aAdd(aDados, {	&cCpoMat,;	//-01
						&cCpoPD,;	//-02
						&cCpoVRB,;	//-03
						"",;		//-04-ANO
						0,;			//-05-MES 01
						0,;			//-06-MES 02
						0,;			//-07-MES 03
						0,;			//-08-MES 04
						0,;			//-09-MES 05
						0,;			//-10-MES 06
						0,;			//-11-MES 07
						0,;			//-12-MES 08
						0,;			//-13-MES 09
						0,;			//-14-MES 10
						0,;			//-15-MES 11
						0 })		//-16-MES 12
		nPos := Len(aDados)
	Else
	EndIf

	Do Case
		Case cMes == "01"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,05] += &cCpoVLR
				Elseif (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,05] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 		    aDados[nPos,05] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
				        PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 		        aDados[nPos,05] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "02"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,06] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,06] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 		    aDados[nPos,06] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
				        PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 		        aDados[nPos,06] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "03"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,07] += &cCpoVLR
				Elseif (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,07] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 		    aDados[nPos,07] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
				        PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 		        aDados[nPos,07] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "04"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,08] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,08] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 		    aDados[nPos,08] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
				        PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 		        aDados[nPos,08] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "05"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2],  QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					 PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,09] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,09] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,09] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,09] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "06"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,10] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,10] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
				    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 		    aDados[nPos,10] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,10] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "07"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,11] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,11] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,11] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,11] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "08"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,12] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,12] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,12] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,12] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "09"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,13] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,13] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,13] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					 	PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,13] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "10"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,14] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,14] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,14] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,14] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "11"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,15] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,15] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,15] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,15] -= &cCpoVLR
				Endif
			Endif

		Case cMes == "12"
			aDados[nPos,04] := cAno
			If cAlias == "QSRC"
				If (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="3" )
					aDados[nPos,16] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
						PosSrv(aDados[nPos,2], QSRC->RC_FILIAL,"RV_TIPOCOD")=="4" )
		 				aDados[nPos,16] -= &cCpoVLR
				Endif

			ElseIF cAlias == "QSRD"
				If (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="1" .OR.  ;
					PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="3" )
		 			aDados[nPos,16] += &cCpoVLR
				ElseIf (PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="2" .OR.  ;
					    PosSrv(aDados[nPos,2], QSRD->RD_FILIAL,"RV_TIPOCOD")=="4" )
		 			    aDados[nPos,16] -= &cCpoVLR
				Endif
			Endif
	EndCase

	dbSkip() //Avanca o ponteiro do registro no arquivo
EndDo

aSort(aDados,,,{|x,y| x[1]+x[4]+x[2] < y[1]+y[4]+y[2]}) //# Ordena por Matricula + Ano + Verba

Return



/******************************/
Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

Local nX   := 0
Local cMat := ""
Local nComum := 22	//23

Local nTot01 := 0
Local nTot02 := 0
Local nTot03 := 0
Local nTot04 := 0
Local nTot05 := 0
Local nTot06 := 0
Local nTot07 := 0
Local nTot08 := 0
Local nTot09 := 0
Local nTot10 := 0
Local nTot11 := 0
Local nTot12 := 0

Local nCol01 := 028
Local nCol02 := 043
Local nCol03 := 058
Local nCol04 := 073
Local nCol05 := 088
Local nCol06 := 103
Local nCol07 := 118
Local nCol08 := 133
Local nCol09 := 148
Local nCol10 := 163
Local nCol11 := 178
Local nCol12 := 193

Local nInc00 := Iif( (nArr1Mes+00)> 16, ((nArr1Mes+00)-nComum), 00 )
Local nInc01 := Iif( (nArr1Mes+01)> 16, ((nArr1Mes+01)-nComum), 01 )
Local nInc02 := Iif( (nArr1Mes+02)> 16, ((nArr1Mes+02)-nComum), 02 )
Local nInc03 := Iif( (nArr1Mes+03)> 16, ((nArr1Mes+03)-nComum), 03 )
Local nInc04 := Iif( (nArr1Mes+04)> 16, ((nArr1Mes+04)-nComum), 04 )
Local nInc05 := Iif( (nArr1Mes+05)> 16, ((nArr1Mes+05)-nComum), 05 )
Local nInc06 := Iif( (nArr1Mes+06)> 16, ((nArr1Mes+06)-nComum), 06 )
Local nInc07 := Iif( (nArr1Mes+07)> 16, ((nArr1Mes+07)-nComum), 07 )
Local nInc08 := Iif( (nArr1Mes+08)> 16, ((nArr1Mes+08)-nComum), 08 )
Local nInc09 := Iif( (nArr1Mes+09)> 16, ((nArr1Mes+09)-nComum), 09 )
Local nInc10 := Iif( (nArr1Mes+10)> 16, ((nArr1Mes+10)-nComum), 10 )
Local nInc11 := Iif( (nArr1Mes+11)> 16, ((nArr1Mes+11)-nComum), 11 )

dbSelectArea("SRA")
dbSetorder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta o cabecalho de impressao...                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//#                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//#       0123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+123456789+
//Cabec1 := " Descricao da Verba            Janeiro        Fevereiro      Marco          Abril          Maio           Junho          Julho          Agosto         Setembro       Outubro        Novembro       Dezembro
//#           999 XxxxxxxxxXxxxxxxxxxX   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99   9,999,999.99

Cabec1 := STR0019 +	fDescMes((n1Mes+00),15)+;
					fDescMes((n1Mes+01),15)+;
					fDescMes((n1Mes+02),15)+;
					fDescMes((n1Mes+03),15)+;
					fDescMes((n1Mes+04),15)+;
					fDescMes((n1Mes+05),15)+;
					fDescMes((n1Mes+06),15)+;
					fDescMes((n1Mes+07),15)+;
					fDescMes((n1Mes+08),15)+;
					fDescMes((n1Mes+09),15)+;
					fDescMes((n1Mes+10),15)+;
					fDescMes((n1Mes+11),15)
Cabec2 := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetRegua(Len(aDados))

For nX := 1 to Len(aDados)

	//#IncRegua()	//-Incrementa regua padrao de processamento em relatorios
	IncProc(STR0018+aDados[nX,01]+"-"+aDados[nX,02])

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o cancelamento pelo usuario...                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nLin > 65 .Or. cMat != aDados[nX,01]
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8

		If cMat != aDados[nX,01]
			cMat := aDados[nX,01]

			nTot01 := 0
			nTot02 := 0
			nTot03 := 0
			nTot04 := 0
			nTot05 := 0
			nTot06 := 0
			nTot07 := 0
			nTot08 := 0
			nTot09 := 0
			nTot10 := 0
			nTot11 := 0
			nTot12 := 0
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o Cadastro de Funcionario e imprime ...                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSeek(xFilial("SRA")+aDados[nX,01],.F.)

	@nLin,001 PSAY aDados[nX,01] +Space(02)+ SRA->RA_NOME
	nLin += 2 // Avanca a linha de impressao

	While nX <= Len(aDados) .And. cMat == aDados[nX,01]

		@nLin,001 PSAY aDados[nX,02]
		@nLin,005 PSAY aDados[nX,03]

		If ValType(aDados[nX,(nArr1Mes+nInc00)]) != "N"
			@nLin,nCol01 PSAY "0,00"	//Posicao 05
			nTot01 += 0
		Else
			@nLin,nCol01 PSAY Transform(aDados[nX,(nArr1Mes+nInc00)],"@E 9,999,999.99")	//Posicao 05
			nTot01 += aDados[nX,(nArr1Mes+nInc00)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc01)]) != "N"
			@nLin,nCol02 PSAY "0,00"	//Posicao 06
			nTot02 += 0
		Else
			@nLin,nCol02 PSAY Transform(aDados[nX,(nArr1Mes+nInc01)],"@E 9,999,999.99")	//Posicao 06
			nTot02 += aDados[nX,(nArr1Mes+nInc01)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc02)]) != "N"
			@nLin,nCol03 PSAY "0,00"
			nTot03 += 0
		Else
			@nLin,nCol03 PSAY Transform(aDados[nX,(nArr1Mes+nInc02)],"@E 9,999,999.99")	//Posicao 07
			nTot03 += aDados[nX,(nArr1Mes+nInc02)]
		Endif

		If  Valtype(aDados[nX,(nArr1Mes+nInc03)]) != "N"
			@nLin,nCol04 PSAY "0,00"	//Posicao 08
			nTot04 += 0
		Else
			@nLin,nCol04 PSAY Transform(aDados[nX,(nArr1Mes+nInc03)],"@E 9,999,999.99")	//Posicao 08
			nTot04 += aDados[nX,(nArr1Mes+nInc03)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc04)]) != "N"
			@nLin,nCol05 PSAY "0,00"	//Posicao 09
			nTot05 += 0
		Else
			@nLin,nCol05 PSAY Transform(aDados[nX,(nArr1Mes+nInc04)],"@E 9,999,999.99")	//Posicao 09
			nTot05 += aDados[nX,(nArr1Mes+nInc04)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc05)]) != "N"
			@nLin,nCol06 PSAY "0,00"	//Posicao 10
			nTot06 += 0
		Else
			@nLin,nCol06 PSAY Transform(aDados[nX,(nArr1Mes+nInc05)],"@E 9,999,999.99")	//Posicao 10
			nTot06 += aDados[nX,(nArr1Mes+nInc05)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc06)]) != "N"
			@nLin,nCol07 PSAY "0,00"//Posicao 11
			nTot07 += 0
		Else
			@nLin,nCol07 PSAY Transform(aDados[nX,(nArr1Mes+nInc06)],"@E 9,999,999.99")	//Posicao 11
			nTot07 += aDados[nX,(nArr1Mes+nInc06)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc07)]) != "N"
			@nLin,nCol08 PSAY "0,00"	//Posicao 12
			nTot08 += 0
		Else
			@nLin,nCol08 PSAY Transform(aDados[nX,(nArr1Mes+nInc07)],"@E 9,999,999.99")	//Posicao 12
			nTot08 += aDados[nX,(nArr1Mes+nInc07)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc08)]) != "N"
			@nLin,nCol09 PSAY "0,00"	//Posicao 13
			nTot09 += 0
		Else
			@nLin,nCol09 PSAY Transform(aDados[nX,(nArr1Mes+nInc08)],"@E 9,999,999.99")	//Posicao 13
			nTot09 += aDados[nX,(nArr1Mes+nInc08)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc09)]) != "N"
			@nLin,nCol10 PSAY "0,00" //Posicao 14
			nTot10 += 0
		Else
			@nLin,nCol10 PSAY Transform(aDados[nX,(nArr1Mes+nInc09)],"@E 9,999,999.99")	//Posicao 14
			nTot10 += aDados[nX,(nArr1Mes+nInc09)]
		Endif

		If  Valtype(aDados[nX,(nArr1Mes+nInc10)]) != "N"
			@nLin,nCol11 PSAY "0,00"	//Posicao 15
			nTot11 += 0
		Else
			@nLin,nCol11 PSAY Transform(aDados[nX,(nArr1Mes+nInc10)],"@E 9,999,999.99")	//Posicao 15
			nTot11 += aDados[nX,(nArr1Mes+nInc10)]
		Endif

		If Valtype(aDados[nX,(nArr1Mes+nInc11)]) != "N"
			@nLin,nCol12 PSAY "0,00" 	//Posicao 16
			nTot12 += 0
		Else
			@nLin,nCol12 PSAY Transform(aDados[nX,(nArr1Mes+nInc11)],"@E 9,999,999.99")	//Posicao 16
			nTot12 += aDados[nX,(nArr1Mes+nInc11)]
		Endif

		nX += 1

		nLin += 1 // Avanca a linha de impressao
	EndDo

	//# Imprime os Totais do Funcionario
	nLin += 1 // Avanca a linha de impressao
	@nLin,nCol01 PSAY Transform(nTot01,"@E 9,999,999.99")
	@nLin,nCol02 PSAY Transform(nTot02,"@E 9,999,999.99")
	@nLin,nCol03 PSAY Transform(nTot03,"@E 9,999,999.99")
	@nLin,nCol04 PSAY Transform(nTot04,"@E 9,999,999.99")
	@nLin,nCol05 PSAY Transform(nTot05,"@E 9,999,999.99")
	@nLin,nCol06 PSAY Transform(nTot06,"@E 9,999,999.99")
	@nLin,nCol07 PSAY Transform(nTot07,"@E 9,999,999.99")
	@nLin,nCol08 PSAY Transform(nTot08,"@E 9,999,999.99")
	@nLin,nCol09 PSAY Transform(nTot09,"@E 9,999,999.99")
	@nLin,nCol10 PSAY Transform(nTot10,"@E 9,999,999.99")
	@nLin,nCol11 PSAY Transform(nTot11,"@E 9,999,999.99")
	@nLin,nCol12 PSAY Transform(nTot12,"@E 9,999,999.99")

	nX -= 1
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



/******************************/
Static Function ImpOK()
Return



/******************************/
Static Function Menos1Ano(dData)
Local nMes := Month(dData)
Local nAno := Year(dData)

If Month(dData) = 12
	dData := CTOD("01/01/"+StrZero(nAno,4))
Else
	dData := dData - 365
	nAno  := Year(dData)

	If Month(dData) <= nMes
		nMes := nMes+1
		dData := CTOD("01/"+StrZero(nMes,2)+"/"+StrZero(nAno,4))
	Else
		dData := CTOD("01/"+StrZero(Month(dData),2)+"/"+StrZero(nAno,4))
	EndIf
EndIf
Return(dData)

/******************************/
Static Function fDescMes(nMes,nLetras)

Local cMes[12]
Local cRet := ""

If nMes < 0
	nMes := Month(dDataBase)
ElseIf nMes > 12
	nMes := nMes-12
EndIf

If nLetras = NIL
	nLetras := 9
Endif

cMes := {STR0001,STR0002,STR0003,STR0004,STR0005,STR0006,;  	//"Janeiro  "###"Fevereiro"###"Marco    "###"Abril    "###"Maio     "###"Junho    "
		 STR0007,STR0008,STR0009,STR0010,STR0011,STR0012}   	//"Julho    "###"Agosto   "###"Setembro "###"Outubro  "###"Novembro "###"Dezembro "

cRet := Subs(cMes[nMes]+Space(nLetras),1,nLetras)

Return(cRet)
