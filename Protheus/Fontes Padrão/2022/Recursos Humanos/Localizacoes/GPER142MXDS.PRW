#include "protheus.ch"
#include "Birtdataset.ch"
#INCLUDE "GPER142MEX.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GPER142MXDS  ³Autor Jonathan Gonzalez Rivera          | Data ³25/09/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ DEfinicion de dataset que sera utilizado en el reporte de Finiquitos en³±±
±±³          ³ formato BIRT para Mexico                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER142MXDS()                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER142MEX                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data	   ³    Chamado/Req   ³ Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz|10/12/15|PCDEF2015_2016-892|Se implementa el nuevo grupo de preguntas ³±±
±±³            |        |                  |y se elimina el tratamiento para las      ³±±
±±³            |        |                  |preguntas de tipo RANGE.                  ³±±
±±³            |        |                  |                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Dataset GP142M
	title STR0001 //Carta de Finiquitos BIRT
	description STR0001 //Carta de Finiquitos BIRT
	PERGUNTE "GPR142MEX"

columns
	define column TPRESC	  type character size 15   label STR0002 //Tipo Resc
	define column EMPRESA  type character size 30   label STR0003 //Empresa
	define column VALRESC  type character size 20   label STR0004 //valor rescision
	define column VALLETR  type character size 100  label STR0005 //valor letra
	define column CAUSA    type character size 100  label STR0006 //causa despido
	define column DEDUNID  type character size 10   label STR0007 //deduc. unid.
	define column DEDCONP  type character size 50   label STR0008 //deduc. Conc.
	define column DEDIMPO  type character size 15   label STR0009 //deduc. importe
	define column PERUNID  type character size 10   label STR0010 //percep. unidades
	define column PERCONP  type character size 50   label STR0011 //percep. Coceptos
	define column PERIMPO  type character size 15   label STR0012 //percep. importe
	define column NOME     type character size 40   label STR0013 //Nombre
	define column MATRICL  type character size 10   label STR0014 //Matricula
	define column RFC      type character size 15   label STR0015 //RFC
	define column DTDEMIS  type character size 10   label STR0016 //Fecha Despido
	define column RGIMSS   type character size 15   label STR0017 //Registro IMSS
	define column CURP     type character size 20   label STR0018 //CURP
	define column KEYLOC   type character size 10   label STR0019 //Loc Pago
	define column TOTPERC  type character size 15   label STR0020 //Total percep
	define column TOTDEDU  type character size 15   label STR0025 //Total deduc
	define column LOGOEMP  type character size 30   label STR0026 //Logotipo
	define column FLAGPER  type character size 1    label STR0027 //FLAG
	define column FLAGDED  type character size 1    label STR0027 //FLAG
	define column RODAPE   type character size 1900 label STR0028 //Pie Pagina

define query "SELECT TPRESC , EMPRESA, VALRESC, VALLETR, CAUSA, DEDUNID, DEDCONP, "+;
                   " DEDIMPO, PERUNID, PERCONP, PERIMPO, NOME , MATRICL, LOGOEMP, "+;
                   " DTDEMIS, RGIMSS , TOTDEDU, KEYLOC , CURP , TOTPERC, FLAGPER, "+;
                   " FLAGDED, RODAPE , RFC "+;
             "FROM %WTable:1% "

process dataset
	Local cWTabAlias
	Local lRet    := .F.

	Private cFilialDe    //Sucursal Inicial
	Private cFilialAte   //Sucursal Final
	Private cMatDe       //Matricula Inicial
	Private cMatAte      //Matricula Final
	Private cCostoDe     //Centro Costo Inicial
	Private cCostoAte    //Centro Costo Final
	Private cTipoRes		//TIPO RESCICION
	Private cPiePagina	//Pie de Pagina
	Private cPeriodo     //Periodo de Calculo
	Private cNumPago     //Numero de pago

		cFilialDe   := self:execParamValue( "MV_PAR01" )
		cFilialAte  := self:execParamValue( "MV_PAR02" )
		cMatDe      := self:execParamValue( "MV_PAR03" )
		cMatAte     := self:execParamValue( "MV_PAR04" )
		cCostoDe    := self:execParamValue( "MV_PAR05" )
		cCostoAte   := self:execParamValue( "MV_PAR06" )
		cTipoRes    := self:execParamValue( "MV_PAR07" )
		cPiePagina  := self:execParamValue( "MV_PAR08" )
		cPeriodo    := self:execParamValue( "MV_PAR09" )
		cNumPago    := self:execParamValue( "MV_PAR10" )

		//VE RODAPE DO RECIBO
		cRodape	:= AllTrim( fPosTab( "S022", cPiePagina, "=", 4,,,,5) )//	RODAPE DO RECIBO

		if ::isPreview()
		endif

		cWTabAlias := ::createWorkTable()
		chkFile("SRA")

		Processa({|_lEnd| lRet := GP142MXIMP(cWTabAlias)}, ::title())

		if !lRet
			MsgInfo(STR0023) //"No existen datos dentro de los rangos seleccionados"
		else
			MsgInfo(STR0024) //"Impresion Terminada"
		endif

return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GP142MXIMP³Autor Jonathan Gonzalez Rivera           | Data ³25/09/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ funcion encargada de la extraccion de informacion, tratamiento y del ³±±
±±³          ³ dataset GP142M (Carta de Finiquitos BIRT) del reporte.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GP142MXIMP(EXPC1, EXPL1)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPER142MXDS                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tabla Temporal                                               ³±±
±±³          ³ Expl1 = Variable de control para archivo vacio                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data	   ³    Chamado/Req ³ Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            |        |                |                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GP142MXIMP(cWTabAlias )
	Local nHoras   	:= ""
	Local cSvRoteir	:= "IN ('"+fGetCalcRot('4')+"' , '"+fGetCalcRot('A')+"')" // Calculo de Rescisao y Aplicacao de Rescisao
	local cSrvTIPCOD	:= "IN ('1','2')"
	Local cAcessaSRC	:= &( " { || " + ChkRH( "GPER140" , "SRC" , "2" ) + " } " )
	Local cAcessaSRA	:= &( " { || " + ChkRH( "GPER140" , "SRA" , "2" ) + " } " )
	Local nImprime	:= 0
	Local cTemp		:= getNextAlias()
	Local cCposQuery	:= ""
	Local cCposFrom	:= ""
	Local cWhere		:= ""
	Local cGroup		:= ""
	Local cOrder		:= ""
	Local nCount		:= 0
	Local cFIL			:= ""
	Local cMAT			:= ""
	Local cPROCES		:= ""
	Local cROTEIR		:= "|"+fGetCalcRot('4')+"|"+fGetCalcRot('A')+"|"
	Local lSelec		:= .f.
	Local dDtDemi

	//Declaracion de Variables privadas
	Private nProv		:= nDesc := 0.00
	Private aPdv		:= {}
	Private aPdd		:= {}
	Private aCodFol	:= {}         // Matriz com Codigo da folha
	Private aInfo		:= {}         // Matriz com dados da empresa
	Private cFiliAnt := "__cFiliAnt__"

		cursorwait()

			cCposQuery	:= "% SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_RG, SRA.RA_CURP, SRA.RA_CIC, "
			cCposQuery	+= " SRA.RA_CC, SRA.RA_PROCES,  SRA.RA_TIPOAFA, SRA.RA_KEYLOC, SRA.RA_DEMISSA, "
			cCposQuery	+= " SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_PD , SRC.RC_PROCES, SRC.RC_ROTEIR, "
			cCposQuery	+= " SRC.RC_PERIODO, SRC.RC_SEMANA, SRC.RC_TIPO1, SRC.RC_HORAS, SRV.RV_TIPOCOD,"
			cCposQuery	+= " SRV.RV_COD,SRV.RV_DESC, SRG.RG_DATADEM, SRG.RG_EFETIVA, SUM(SRC.RC_VALOR) RC_VALOR %"

			cCposFrom	:= "% " + RetSqlName("SRA") + " SRA, "
			cCposFrom	+=  RetSqlName("SRV")+ " SRV, "
			cCposFrom	+=  RetSqlName("SRG")+ " SRG, "
			cCposFrom	+=  RetSqlName("SRC")+ " SRC  %"

			cWhere := "% SRA.RA_FILIAL BETWEEN '"+ cFilialDe +"' AND '"+ cFilialAte + "' "
			cWhere += " AND SRA.RA_MAT BETWEEN '"+ cMatDe +"' AND '"+ cMatAte + "' "
			cWhere += " AND SRA.RA_CC BETWEEN '"+ cCostoDe +"' AND '"+ cCostoAte + "' "
			cWhere += " AND SRC.RC_PERIODO = '"+ cPeriodo +"' "
	  		cWhere += " AND SRC.RC_SEMANA = '"+ cNumPago +"' "
			cWhere += " AND SRC.RC_FILIAL = SRA.RA_FILIAL "
			cWhere += " AND SRG.RG_FILIAL = SRA.RA_FILIAL "
			cWhere += " AND SRC.RC_MAT = SRA.RA_MAT "
			cWhere += " AND SRG.RG_MAT = SRA.RA_MAT "
			cWhere += " AND SRC.RC_PROCES = SRA.RA_PROCES "
			cWhere += " AND SRG.RG_PROCES = SRA.RA_PROCES "
			cWhere += " AND SRC.RC_VALOR <> 0 "
			cWhere += " AND SRC.RC_ROTEIR " + cSvRoteir + " "
			cWhere += " AND SRV.RV_TIPOCOD " + cSrvTIPCOD + " "
	  		cWhere += " AND SRC.RC_PD = SRV.RV_COD "

			If ( TcSrvType()=="AS/400" )
				cWhere += "     AND SRC.@DELETED@  = ' ' "
				cWhere += "     AND SRV.@DELETED@  = ' ' "
				cWhere += "     AND SRG.@DELETED@  = ' ' "
				cWhere += "     AND SRA.@DELETED@  = ' '%"
			ELSE
				cWhere += "     AND SRC.D_E_L_E_T_  = ' ' "
				cWhere += "     AND SRV.D_E_L_E_T_  = ' ' "
				cWhere += "     AND SRG.D_E_L_E_T_  = ' ' "
				cWhere += "     AND SRA.D_E_L_E_T_  = ' '%"
			ENDIF

			cGroup	:= "% SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_RG, SRA.RA_CURP, SRA.RA_CIC, SRA.RA_CC, "
			cGroup	+= " SRA.RA_PROCES, SRA.RA_TIPOAFA, SRA.RA_KEYLOC, SRA.RA_DEMISSA, SRC.RC_FILIAL, SRC.RC_MAT, "
			cGroup	+= " SRC.RC_PD, SRC.RC_PROCES, SRC.RC_ROTEIR, SRC.RC_PERIODO, SRC.RC_SEMANA, SRC.RC_TIPO1, "
			cGroup	+= " SRC.RC_HORAS, SRV.RV_TIPOCOD, SRV.RV_COD, SRV.RV_DESC, SRG.RG_DATADEM, SRG.RG_EFETIVA %"

			cOrdem := "% SRA.RA_FILIAL, SRA.RA_MAT, SRC.RC_PD, SRC.RC_PROCES, "
			cOrdem += " SRC.RC_ROTEIR, SRC.RC_PERIODO, SRC.RC_SEMANA %"

			BeginSql alias cTemp
				SELECT   %exp:cCposQuery%
				FROM  %exp:cCposFrom%
				WHERE %exp:cWhere%
				GROUP BY %exp:cGroup%
				ORDER BY %exp:cOrdem%
			EndSql

			TCSetField(cTemp,"RA_DEMISSA","D")
			TCSetField(cTemp,"RG_DATADEM","D")

		cursorarrow()

		dbSelectArea( cTemp )

		Count to nCount

		(cTemp)->(dbGotop())

		ProcRegua(nCount)

		While (cTemp)->(!EOF())

			aPdv 	:= {}
			aPdd 	:= {}
			lSelec := .f.

			fInfo(@aInfo,(cTemp)->RA_FILIAL)

			//CONSISTE FILIAIS E ACESSOS
			If (cTemp)->( !( RA_FILIAL $ fValidFil() ) .or. !Eval( cAcessaSRA ) )
		      	(cTemp)->( dbSkip() )
		       	Loop
			EndIf

			//CARREGA VARIAVEIS CODIGOS DA FOLHA
			If ( cFiliAnt # (cTemp)->RA_FILIAL )
				cFiliAnt := (cTemp)->RA_FILIAL
				If !fP_CodFol(@aCodFol,cFiliAnt)
					Return
				EndIf
			EndIf

			cFIL		:= (cTemp)->RA_FILIAL
			cMAT		:= (cTemp)->RA_MAT
			cPROCES	:= (cTemp)->RA_PROCES

			nProv := nDesc := 0.00

			While (cTemp)->(!Eof()) .AND. (cTemp)->RC_FILIAL == cFIL .AND. (cTemp)->RC_MAT == cMAT .AND. ;
			                              (cTemp)->RC_PROCES == cPROCES .AND. (cTemp)->RC_ROTEIR $ cROTEIR

				Incproc(STR0029 + cMAT ) //"Processando Registro #"
				//CONSISTE FILIAIS E ACESSOS
				If (cTemp)->(!(RC_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRC))
					(cTemp)->( dbSkip() )
					Loop
				EndIf

	 			If (cTemp)->RG_EFETIVA != "1"
					dDtDemi := (cTemp)->RG_DATADEM
				else
					dDtDemi := (cTemp)->RA_DEMISSA
				EndIf

				//VERIfICA O TIPO DA VERBA E CARREGA NO aPd CORRESPONDENTE
				nHoras	:= If((cTemp)->RC_TIPO1=="H",fConvHoras((cTemp)->RC_HORAS,"1"),(cTemp)->RC_HORAS)
				If (cTemp)->RV_TIPOCOD == "1" //Provento

					Aadd(aPdv,{fDesc("SX5","27"+(cTemp)->RA_TIPOAFA,"X5_DESCSPA",30), (cTemp)->RA_MAT,;
								(cTemp)->RA_CIC, (cTemp)->RA_NOME, (cTemp)->RA_CURP, fDesc("RGC",(cTemp)->RA_KEYLOC,"RGC_DESLOC"),;
								(cTemp)->RA_RG, DTOC(dDtDemi), Str(nHoras,6,2),(cTemp)->RV_DESC,;
								TransForm((cTemp)->RC_VALOR,"99,999,999.99"),(cTemp)->RC_PD } )

					nProv += (cTemp)->RC_VALOR

				ElseIf (cTemp)->RV_TIPOCOD == "2" .And. (cTemp)->RC_PD # aCodfol[126,1]
					Aadd(aPdd,{fDesc("SX5","27"+(cTemp)->RA_TIPOAFA,"X5_DESCSPA",30), (cTemp)->RA_MAT,;
								(cTemp)->RA_CIC, (cTemp)->RA_NOME, (cTemp)->RA_CURP, fDesc("RGC",(cTemp)->RA_KEYLOC,"RGC_DESLOC"),;
								(cTemp)->RA_RG, DTOC(dDtDemi),Str(nHoras,6,2),(cTemp)->RV_DESC,;
								TransForm((cTemp)->RC_VALOR,"99,999,999.99"),(cTemp)->RC_PD} )

					nDesc += (cTemp)->RC_VALOR

				EndIf

				(cTemp)->(dbSkip())

				lSelec := .T.
			EndDo

			If lSelec
				//llena el arreglo con las percepciones
				For nImprime := 1 to Len(aPdv)
					RecLock(cWTabAlias, .T.)

						If cTipoRes == 1
							(cWTabAlias)->TPRESC := STR0021 //"FINIQUITO"
						Else
							(cWTabAlias)->TPRESC := STR0022 //"FINIQUITO ( COMPLEMENTAR )"
						Endif

						(cWTabAlias)->LOGOEMP := "lgrl"+cEmpAnt+".bmp"
						(cWTabAlias)->EMPRESA := aInfo[3]
						(cWTabAlias)->VALRESC := Transform(nProv - nDesc,"999,999,999.99")
						(cWTabAlias)->VALLETR := EXTENSO(nProv - nDesc)
						(cWTabAlias)->CAUSA   := ALLTRIM(aPdv[nImprime,1])
						(cWTabAlias)->MATRICL := aPdv[nImprime,2]
						(cWTabAlias)->RFC     := aPdv[nImprime,3]
						(cWTabAlias)->NOME    := aPdv[nImprime,4]
						(cWTabAlias)->CURP    := aPdv[nImprime,5]
						(cWTabAlias)->KEYLOC  := aPdv[nImprime,6]
						(cWTabAlias)->RGIMSS  := aPdv[nImprime,7]
						(cWTabAlias)->DTDEMIS := aPdv[nImprime,8]
						(cWTabAlias)->PERUNID := aPdv[nImprime,9]
						(cWTabAlias)->PERCONP := aPdv[nImprime,12] + " - " + aPdv[nImprime,10]
						(cWTabAlias)->PERIMPO := aPdv[nImprime,11]
						(cWTabAlias)->FLAGPER := "P" //bandera para deducciones
						(cWTabAlias)->TOTDEDU := Transform(nDesc,"99,999,999.99") //total deducciones
						(cWTabAlias)->TOTPERC := Transform(nProv,"99,999,999.99") //total Percepcion
						//Pie de Pagina
						If Type("cRodape") <> "U"
							(cWTabAlias)->RODAPE  := cRodape
						EndIf

					(cWTabAlias)->(MsUnlock())
				Next nImprime

				//llena el dataset con las deducciones
				For nImprime := 1 to Len(aPdd)
					RecLock(cWTabAlias, .T.)

						If cTipoRes == 1
							(cWTabAlias)->TPRESC := STR0021 //"FINIQUITO"
						Else
							(cWTabAlias)->TPRESC := STR0022 //"FINIQUITO ( COMPLEMENTAR )"
						Endif

						(cWTabAlias)->LOGOEMP := "lgrl"+cEmpAnt+".bmp"
						(cWTabAlias)->EMPRESA := aInfo[3]
						(cWTabAlias)->VALRESC := Transform(nProv - nDesc,"999,999,999.99")
						(cWTabAlias)->VALLETR := EXTENSO(nProv - nDesc)
						(cWTabAlias)->CAUSA   := ALLTRIM(aPdd[nImprime,1])
						(cWTabAlias)->MATRICL := aPdd[nImprime,2]
						(cWTabAlias)->RFC     := aPdd[nImprime,3]
						(cWTabAlias)->NOME    := aPdd[nImprime,4]
						(cWTabAlias)->CURP    := aPdd[nImprime,5]
						(cWTabAlias)->KEYLOC  := aPdd[nImprime,6]
						(cWTabAlias)->RGIMSS  := aPdd[nImprime,7]
						(cWTabAlias)->DTDEMIS := aPdd[nImprime,8]
						(cWTabAlias)->DEDUNID := aPdd[nImprime,9]
						(cWTabAlias)->DEDCONP := aPdd[nImprime,12] + " - " + aPdd[nImprime,10]
						(cWTabAlias)->DEDIMPO := aPdd[nImprime,11]
						(cWTabAlias)->FLAGDED := "D" //bandera para deducciones
						(cWTabAlias)->TOTDEDU := Transform(nDesc,"99,999,999.99") //Total deducciones
						(cWTabAlias)->TOTPERC := Transform(nProv,"99,999,999.99") //Total Percepcion
						//Pie de Pagina
						If Type("cRodape") <> "U"
							(cWTabAlias)->RODAPE  := cRodape
						EndIf

					(cWTabAlias)->(MsUnlock())
				Next nImprime

				aInfo	:= {}

			EndIf

		EndDo

	lRet := nCount > 0

Return lRet
