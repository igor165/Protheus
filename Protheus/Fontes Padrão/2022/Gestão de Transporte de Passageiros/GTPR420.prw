#Include 'Protheus.ch'
#INCLUDE 'GTPR420.CH'
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR420
Geração Mapa Movimento Metropolitano
@type function
@author crisf
@since 02/12/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Function GTPR420()

Local cPerg		:= "GTPR420"
Private oReport

If Pergunte(cPerg,.T.)
	
	oReport:= ReportDef()
	oReport:PrintDialog()

Else
	Alert( STR0009 )//"Cancelado pelo usuário"
EndIf

Return

/*/{Protheus.doc} ValidPerg
(long_description)
@type  Static Function
@author user
@since 07/10/2020
@version version
@param , param_type, param_descr
@return lRet, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidPerg()
Local lRet  := .T.
Local cPerg	:= "GTPR420"
//Mes/Ano
If Empty(MV_PAR01) .OR.  Empty(MV_PAR02) 
	
	Help(,,"Help", cPerg+"MESANO", STR0004, 1, 0)// "Verificar se o Mês(MM) e o Ano(AAAA) estão preenchidos."
	lRet := .F.
	
EndIf

//Validando o Mês informado
If !lRet .AND. (MV_PAR01 < 0 .OR.  MV_PAR01 > 12)
	
	Help(,,"Help", cPerg+"MES", STR0005, 1, 0)// "Informar o mês corretamente."
	lRet := .F.
	
EndIf

//Validando o Ano informado
If !lRet .AND. MV_PAR02 < 2015
	
	Help(,,"Help", cPerg+"ANO", STR0006, 1, 0)//"Informar o ano com 4 digitos (formato AAAA) e a partir de 2015."
	lRet := .F.
	
EndIf			

//Validando o preenchimento do 'Codigo da Linha' se o 'Tipo de Linha' não tiver preenchido.						
If  !lRet .AND. (Empty(MV_PAR03) .Or. Empty(MV_PAR04))

	if  Empty(MV_PAR05)
					
		Help(,,"Help", cPerg+"LINHA", , 1, 0)//"Deve-se informar pelo menos o código da Linha."
		lRet := .F.
	
	EndIf
		
EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author crisf
@since 02/12/2017
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ReportDef()	
Local cPerg		:= "GTPR420"
Local cTitulo	:= STR0002//"Mapa Movimento Metropolitano"
Local cDescrRel	:= STR0003//"Listará a Linhas versus movimentações."
Local oReport
Local oSection1
Local oSection2
Local oSection3	
Local oSection4

oReport:= TReport():New(cPerg+"_"+StrTran(Time(),":",""), cTitulo, cPerg, {|oReport| ReportPrint( oReport )}, cDescrRel)
oReport:SetLandscape()

oSection1 := TRSection():New(oReport, cTitulo, {"GI2"})
TRCell():New(oSection1,"M0_FILIAL" ,"SM0", "Empresa"       , /*Picture*/, 50                     , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"TMP_DIA"   ,"TMP", "Referente"     , /*Picture*/, 25                     , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_PREFIX","GI2", "Prefixo"       , /*Picture*/, 70                     , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_NUMLIN","GI2", "Linha"         , /*Picture*/, TamSX3("GI2_NUMLIN")[1], /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"TMP_SENTID","TMP", "Sentido"       , /*Picture*/, 6                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_KMTOTA","GI2", "Extensão"      , /*Picture*/, TamSX3("GI2_KMTOTA")[1], /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_HRPADR","GI2", "Percurso"      , /*Picture*/, TamSX3("GI2_HRPADR")[1], /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_PONPAR","GI2", "Parada"        , /*Picture*/, TamSX3("GI2_PONPAR")[1], /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection1,"GI2_KMMED" ,"GI2", "Vel. Média"    , /*Picture*/, TamSX3("GI2_KMMED")[1] , /*lPixel*/, /*{|| code-block de impressao }*/)
oSection1:SetHeaderSection(.T.)  

oSection2 := TRSection():New(oReport,cTitulo, {"GIC"})
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"TMP_HORA" ,"TMP", "HORA" , /*Picture*/, 6                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_CARRO","TMP", "CARRO", /*Picture*/, 6                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_CAP"  ,"TMP", "CAP"  , /*Picture*/, 3                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_01"    ,"TMP", "1"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_02"    ,"TMP", "2"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_03"    ,"TMP", "3"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_04"    ,"TMP", "4"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_05"    ,"TMP", "5"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_06"    ,"TMP", "6"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_07"    ,"TMP", "7"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_08"    ,"TMP", "8"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_09"    ,"TMP", "9"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_10"   ,"TMP", "10"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_11"   ,"TMP", "11"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_12"   ,"TMP", "12"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_13"   ,"TMP", "13"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_14"   ,"TMP", "14"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_15"   ,"TMP", "15"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_16"   ,"TMP", "16"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_17"   ,"TMP", "17"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_18"   ,"TMP", "18"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_19"   ,"TMP", "19"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_20"   ,"TMP", "20"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_21"   ,"TMP", "21"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_22"   ,"TMP", "22"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_23"   ,"TMP", "23"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_24"   ,"TMP", "24"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_25"   ,"TMP", "25"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_26"   ,"TMP", "26"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_27"   ,"TMP", "27"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_28"   ,"TMP", "28"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_29"   ,"TMP", "29"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_30"   ,"TMP", "30"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_31"   ,"TMP", "31"   , /*Picture*/, 4                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_MEDIA","TMP", "MÉDIA", /*Picture*/, 6                      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection2,"TMP_TOTAL","TMP", "TOTAL", /*Picture*/, 6                      , /*lPixel*/, /*{|| code-block de impressao }*/)

TRFunction():New(oSection2:Cell("TMP_HORA" ),NIL,"TIMESUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_CARRO"),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_CAP"  ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_01"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_02"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_03"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_04"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_05"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_06"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_07"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_08"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_09"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_10"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_11"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_12"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_13"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_14"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_15"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_16"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_17"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_18"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_19"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_20"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_21"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_22"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_23"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_24"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_25"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_26"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_27"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_28"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_29"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_30"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_31"   ),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_MEDIA"),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)
TRFunction():New(oSection2:Cell("TMP_TOTAL"),NIL,"SUM",,,"@E 999",,.F.,.F.,.F.,,)

oSection3 := TRSection():New(oReport, "HORÁRIO IDA + VOLTA", {"GYN"})
TRCell():New(oSection3,"TMP_DUTESI","TMP", "Dias Utéis Ida"         , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"TMP_DUTESV","TMP", "Dias Utéis Volta"       , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"TMP_SABADI","TMP", "Sabados Ida"            , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"TMP_SABADV","TMP", "Sabados Volta"          , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"TMP_FERDOI","TMP", "Feriados/Domingo Ida"   , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection3,"TMP_FERDOV","TMP", "Feriados/Domingo Volta" , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
oSection3:SetHeaderSection(.T.) 


oSection4 := TRSection():New(oReport, "VEÍCULOS UTILIZADOS", {"ST9"})
TRCell():New(oSection4,"VEI_DUTESI","TMP", "Dias Utéis Normal"      , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection4,"VEI_DUTESV","TMP", "Dias Utéis Extra"       , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection4,"VEI_SABADI","TMP", "Sabados Normal"         , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection4,"VEI_SABADV","TMP", "Sabados Extra"          , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection4,"VEI_FERDOI","TMP", "Feriados/Domingo Normal", /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSection4,"VEI_FERDOV","TMP", "Feriados/Domingo Extra" , /*Picture*/, 6 , /*lPixel*/, /*{|| code-block de impressao }*/)
oSection4:SetHeaderSection(.T.) 

oReport:EndPage(.F.)

Return oReport

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author crisf
@since 02/12/2017
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function ReportPrint( oReport)
Local oSection1	 := oReport:Section(1)
Local oSection2	 := oReport:Section(2)
Local oSection3	 := oReport:Section(3)
Local oSection4	 := oReport:Section(4)
Local aDiasPer	 := {}
Local cDiaUtil	 := ""
Local cSabados	 := ""
Local cDomFer	 := ""
Local cDescLinha := ""	
Local nDias      := 0
Local nLnIni     := 0
Local cTmpGI2	 := GetNextAlias()
Local cTmpGIC    := GetNextAlias()
Local CTMPVEIC   := GetNextAlias()
Local cAnoMes	 := ''
local nColAux	 := 0
Local cChLnSrv	 := ''
Local cConteu	 := ''
Local nMedia	 := 0
Local nTtMes	 := 0
Local nCountDay  := 0
Local ntotMed	 := 0
Local nContador	 := 0
Local nLinha     := 0

Pergunte(oReport:uParam,.F.)

If ValidPerg()
	//Carrega os dias do mês/ano informado, separando por dias utéis, sábado, domingo/feriado
	CarreDias( @aDiasPer, @cDiaUtil, @cSabados,  @cDomFer )
	cAnoMes	:= StrZero(MV_PAR02,4)+StrZero(MV_PAR01,2)

	//Pesquisa os dados da linha
	PesqGI2( @cTmpGI2, cAnoMes, cDiaUtil, cSabados, cDomFer)

	if !(cTmpGI2)->(Eof())
		
		oReport:SetMeter((cTmpGI2)->(RecCount()))
		
		oReport:StartPage()	
		oReport:SkipLine()

		While !oReport:Cancel() .AND. (cTmpGI2)->(!Eof())
			nLinha++

			if nLinha > 2
				nLinha := 0
				oReport:EndPage()
			endif 

			oSection1:Init()

			cDescLinha	:= (cTmpGI2)->GI2_PREFIX + " "
			cDescLinha	+= AllTrim(Posicione('GI1',1, xFilial('GI1')+(cTmpGI2)->GI2_LOCINI,"GI1_DESCRI")) + " X "
			cDescLinha	+= AllTrim(Posicione('GI1',1, xFilial('GI1')+(cTmpGI2)->GI2_LOCFIM,"GI1_DESCRI")) + " "
			cDescLinha	+= "("+ AllTrim(Posicione('GQC',1, xFilial('GQC')+(cTmpGI2)->GI2_TIPLIN ,"GQC_DESCRI"))+ ")"
			
			oSection1:Cell("M0_FILIAL" ):SetValue(SM0->M0_FILIAL)
			oSection1:Cell("TMP_DIA"   ):SetValue(STR0012 + MesExtenso(MV_PAR01)+STR0013+StrZero(MV_PAR02,4))
			oSection1:Cell("GI2_PREFIX"):SetValue(cDescLinha)
			oSection1:Cell("GI2_NUMLIN"):SetValue((cTmpGI2)->GI2_NUMLIN)
			oSection1:Cell("TMP_SENTID"):SetValue(IIF((cTmpGI2)->DIAUTIL_IDA > 0,"IDA","VOLTA"))
			oSection1:Cell("GI2_KMTOTA"):SetValue((cTmpGI2)->GI2_KMTOTA)
			oSection1:Cell("GI2_HRPADR"):SetValue((cTmpGI2)->GI2_HRPADR)
			oSection1:Cell("GI2_PONPAR"):SetValue((cTmpGI2)->GI2_PONPAR)
			oSection1:Cell("GI2_KMMED" ):SetValue((cTmpGI2)->GI2_KMMED)
		
			oSection1:PrintLine()
			oReport:SkipLine(2)
			oSection1:Finish()

			//=============================================================================================
			//Carrega os dados dos bilhetes 
			PesqGIC( @cTmpGIC, aDiasPer, cAnoMes, (cTmpGI2)->GYN_LINCOD )
			If !(cTmpGIC)->(Eof())
						
				cChLnSrv	:= (cTmpGIC)->GIC_LINHA+(cTmpGIC)->GYN_HRINI
											
				While  !(cTmpGIC)->(Eof())
					
					nLnIni += 70
					oSection2:Init()
					oSection2:Cell("TMP_HORA" ):SetValue(Transform((cTmpGIC)->GYN_HRINI, "@R 99:99"))
					oSection2:Cell("TMP_CARRO" ):SetValue(Alltrim(Str((cTmpGIC)->CARRO)))

					nCountDay := 0
					
					While cChLnSrv == (cTmpGIC)->GIC_LINHA+(cTmpGIC)->GYN_HRINI

						nColAux := 210
						
						For nDias := 1 to len(aDiasPer)
						
							cConteu	:= &('(cTmpGIC)->TMP_'+aDiasPer[nDias])
							
							oSection2:Cell("TMP_"+aDiasPer[nDias] ):SetValue(Alltrim(Str(cConteu)))
							
							If cConteu > 0
								nCountDay	++
							Endif
							
						Next nDias
					
						nMedia	:= INT(((cTmpGIC)->TOTALBILH/nCountDay))//(cTmpGIC)->MEDIA
						ntotMed += nMedia
						nTtMes	:= (cTmpGIC)->TOTALBILH
						
					(cTmpGIC)->(dbSkip())
						
					EndDo
					
					cChLnSrv	:= (cTmpGIC)->GIC_LINHA+(cTmpGIC)->GYN_HRINI
					
					oSection2:Cell("TMP_MEDIA" ):SetValue(Alltrim(Str(nMedia)))
					oSection2:Cell("TMP_TOTAL" ):SetValue(Alltrim(Str(nTtMes)))
					oSection2:PrintLine()
					nContador += 1
					
				EndDo
				
			EndIf
			//=============================================================================================
			(cTmpGIC)->(DbCloseArea())
			oSection2:Finish()

			//==============================================================================================
			oSection3:Init()
				
			oSection3:Cell("TMP_DUTESI"):SetValue(Alltrim(Str((cTmpGI2)->DIAUTIL_IDA)))
			oSection3:Cell("TMP_DUTESV"):SetValue(Alltrim(Str((cTmpGI2)->DIAUTIL_VOLTA)))
			oSection3:Cell("TMP_SABADI"):SetValue(Alltrim(Str((cTmpGI2)->SABADO_IDA)))
			oSection3:Cell("TMP_SABADV"):SetValue(Alltrim(Str((cTmpGI2)->SABADO_VOLTA)))
			oSection3:Cell("TMP_FERDOI"):SetValue(Alltrim(Str((cTmpGI2)->DOMFER_IDA)))
			oSection3:Cell("TMP_FERDOV"):SetValue(Alltrim(Str((cTmpGI2)->DOMFER_VOLTA)))
			oSection3:PrintLine()
			oSection3:Finish()
			//==============================================================================================

			//==============================================================================================
			PesqVeic(@cTmpVeic, cAnoMes, cDiaUtil, cSabados, cDomFer, (cTmpGI2)->GYN_LINCOD )
			(cTmpVeic)->(dbGotop())
			oSection4:Init()
			if !(cTmpVeic)->(Eof())
				
				oSection4:Cell("VEI_DUTESI"):SetValue(Alltrim(Str((cTmpVeic)->DIAUTIL_N)))
				oSection4:Cell("VEI_DUTESV"):SetValue(Alltrim(Str((cTmpVeic)->DIAUTIL_E)))
				oSection4:Cell("VEI_SABADI"):SetValue(Alltrim(Str((cTmpVeic)->SABADO_N)))
				oSection4:Cell("VEI_SABADV"):SetValue(Alltrim(Str((cTmpVeic)->SABADO_E)))
				oSection4:Cell("VEI_FERDOI"):SetValue(Alltrim(Str((cTmpVeic)->DOMFER_N)))
				oSection4:Cell("VEI_FERDOV"):SetValue(Alltrim(Str((cTmpVeic)->DOMFER_E)))
				oSection4:PrintLine()
			EndIf
			(cTmpVeic)->(dbCloseArea())
			oSection4:Finish()
			//==============================================================================================
			(cTmpGI2)->(DbSkip()) 
		End

		(cTmpGI2)->(DbCloseArea())
		oSection1:Finish()
	EndIf
EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarreDias
(long_description)
@type function
@author jacomo.fernandes
@since 26/06/2018
@version 1.0
@param aDiasPer, array, (Descrição do parâmetro)
@param cDiaUtil, character, (Descrição do parâmetro)
@param cSabados, character, (Descrição do parâmetro)
@param cDomFer, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function CarreDias( aDiasPer, cDiaUtil,  cSabados,  cDomFer )
 	
 	Local dDtBase	:= Ctod('01/'+Str(MV_PAR01)+"/"+Str(MV_PAR02))
 	Local dDtIni	:= dDtBase
	Local dDtFim	:= Ctod(StrZero(last_day(dDtBase),2)+'/'+Str(MV_PAR01)+"/"+Str(MV_PAR02))
	Local dDatI		:= Ctod('//')
	Local aDtFeria	:= {}
	
	Default cDiaUtil:= ""
	Default cSabados:= ""
	Default cDomFer	:= "" 
    //Carrega os feriados		
	aDtFeria	:=  GTPxGetFer( dDtIni, dDtFim )
	 
 	For dDatI := dDtIni to dDtFim
		If Dow(dDatI) == 1 .or. aScan(aDtFeria,{|x| x[1] == DToS(dDatI) }) > 0 // Domingo ou Feriado
			cDomFer	+= "'"+Dtos(dDatI)+"',"
		Elseif Dow(dDatI) == 7 //Sabado
			cSabados	+= "'"+Dtos(dDatI)+"',"
		Else //Dia Ultil
			cDiaUtil	+= "'"+Dtos(dDatI)+"',"
		Endif	
		
		aAdd( aDiasPer, StrZero(Day(dDatI),2) )
		
 	Next dDatI
	cDomFer	 := "%"+SubStr(cDomFer	,1,Len(cDomFer	)-1)+"%"
	cSabados := "%"+SubStr(cSabados ,1,Len(cSabados )-1)+"%"
	cDiaUtil := "%"+SubStr(cDiaUtil ,1,Len(cDiaUtil )-1)+"%"
Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqGI2
Pesquisa e retorna o resumo da(s) linha(s)
@type function
@author crisf
@since 03/12/2017
@version 1.0
@param cTmpGI2, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function PesqGI2( cTmpGI2, cAnoMes, cDiaUtil, cSabados, cDomFer)

	Local cFilGI2	:= ""
	Local cFilGI4	:= '%'+ If(MV_PAR07 <> 3," and GI4.GI4_MSBLQL = '"+STRZERO(MV_PAR07,1)+"' ",'' )+'%'
	
	cFilGI2	+= If(!Empty(MV_PAR05)	," and GI2.GI2_TIPLIN = '"+MV_PAR05+"' "	,'' )
	cFilGI2	+= If(MV_PAR06 <> 3		," and GI2.GI2_MSBLQL = '"+STRZERO(MV_PAR06,1)+"' "	,'' )
	cFilGI2	:= "%"+cFilGI2+"%" 	
		
	BeginSql Alias cTmpGI2

		SELECT 1 as ORD,GYN.GYN_FILIAL,GI2.GI2_KMTOTA, GI2.GI2_NUMLIN,GYN.GYN_LINCOD,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%)  THEN  GYN.GYN_DTINI
			END )AS DIAUTIL_IDA,
		0 AS DIAUTIL_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%) THEN  GYN.GYN_DTINI
			END )AS DIAUTIL_TOTAL,
		
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cSabados%) THEN  GYN.GYN_DTINI
			END )AS SABADO_IDA,
		0 AS SABADO_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cSabados%) THEN  GYN.GYN_DTINI
			END )AS SABADO_TOTAL,
		
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDomFer%) THEN  GYN.GYN_DTINI
			END )AS DOMFER_IDA,
		0 AS DOMFER_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDomFer%) THEN  GYN.GYN_DTINI
			END )AS DOMFER_TOTAL,
		COUNT( GYN.GYN_DTINI )AS TOTAL_IDA,
		0 AS TOTAL_VOLTA,
		COUNT(GYN.GYN_DTINI)AS TOTAL_GERAL,			
		GI2_KMIDA GI2_KMIDA, 
		GI2_HRPADR, 
		GI2_PONPAR, 
		GI2_KMMED, 
		GI2_LOCINI,
		GI2_LOCFIM,
		GI2_TIPLIN,
		GI2_PREFIX	
		FROM %Table:GI2% GI2		       
			INNER JOIN %Table:GYN% GYN ON
				GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_LINCOD = GI2.GI2_COD
				AND GYN.GYN_TIPO = '1'
				AND SUBSTRING(GYN.GYN_DTINI,1,6) = %exp:cAnoMes%	
				AND GYN.%NotDel%
			LEFT JOIN %table:GI4% GI4 ON
				GI4.GI4_FILIAL = GI2.GI2_FILIAL
				AND GI4.GI4_LINHA = GI2.GI2_COD
				AND GI4.GI4_LOCORI = GYN.GYN_LOCORI
				AND GI4.GI4_LOCDES = GYN.GYN_LOCDES
				AND GI4.GI4_HIST = '2'
				AND GI4.%NotDel%
				%exp:cFilGI4%
		WHERE
			GI2.GI2_FILIAL = %xFilial:GI2%
			AND GI2.GI2_NUMLIN BETWEEN %Exp:ALLTRIM(MV_PAR03)% And %Exp:ALLTRIM(MV_PAR04)%
			AND GI2.GI2_HIST = '2'
			AND GI2.%NotDel%
			AND GI2.GI2_KMIDA > 0 
			%exp:cFilGI2%
		GROUP BY GYN.GYN_FILIAL,GI2.GI2_KMTOTA,GI2.GI2_NUMLIN, GYN.GYN_LINCOD, GI2_KMIDA, GI2_HRPADR, GI2_PONPAR, GI2_KMMED, GI2_LOCINI,GI2_LOCFIM,GI2_TIPLIN,GI2_PREFIX	
		
		UNION 
		
		SELECT 2 as ORD,GYN.GYN_FILIAL,GI2.GI2_KMTOTA,GI2.GI2_NUMLIN, GYN.GYN_LINCOD,
		0 AS DIAUTIL_IDA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%)  THEN  GYN.GYN_DTINI
			END )AS DIAUTIL_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%) THEN  GYN.GYN_DTINI
			END )AS DIAUTIL_TOTAL,
		
		0 AS SABADO_IDA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cSabados%) THEN  GYN.GYN_DTINI
			END )AS SABADO_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cSabados%) THEN  GYN.GYN_DTINI
			END )AS SABADO_TOTAL,
		
		0 AS DOMFER_IDA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDomFer%)  THEN  GYN.GYN_DTINI
			END )AS DOMFER_VOLTA,
		COUNT(CASE 
		    WHEN GYN.GYN_DTINI IN (%exp:cDomFer%) THEN  GYN.GYN_DTINI
			END )AS DOMFER_TOTAL,
		0 AS TOTAL_IDA,
		COUNT(GYN.GYN_DTINI )AS TOTAL_VOLTA,
		COUNT(GYN.GYN_DTINI)AS TOTAL_GERAL,			
		GI2_KMVOLT GI2_KMIDA, 
		GI2_HRPADR, 
		GI2_PONPAR, 
		GI2_KMMED, 
		GI2_LOCINI,
		GI2_LOCFIM,
		GI2_TIPLIN,
		GI2_PREFIX	
		FROM %Table:GI2% GI2		       
			INNER JOIN %Table:GYN% GYN ON
				GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_LINCOD = GI2.GI2_COD
				AND GYN.GYN_TIPO = '1'
				AND SUBSTRING(GYN.GYN_DTINI,1,6) = %exp:cAnoMes%
				AND GYN.%NotDel%	
			LEFT JOIN %table:GI4% GI4 ON
				GI4.GI4_FILIAL = GI2.GI2_FILIAL
				AND GI4.GI4_LINHA = GI2.GI2_COD
				AND GI4.GI4_LOCORI = GYN.GYN_LOCORI
				AND GI4.GI4_LOCDES = GYN.GYN_LOCDES
				AND GI4.GI4_HIST = '2'				
				AND GI4.%NotDel%
				%exp:cFilGI4%
		WHERE
			GI2.GI2_FILIAL = %xFilial:GI2%
			AND GI2.GI2_NUMLIN BETWEEN %Exp:ALLTRIM(MV_PAR03)% And %Exp:ALLTRIM(MV_PAR04)%
			AND GI2.GI2_HIST = '2'
			AND GI2.%NotDel%
			AND GI2.GI2_KMVOLT > 0
			%exp:cFilGI2%		
		
		GROUP BY GYN.GYN_FILIAL,GI2.GI2_KMTOTA,GI2.GI2_NUMLIN, GYN.GYN_LINCOD, GI2_KMVOLT, GI2_HRPADR, GI2_PONPAR, GI2_KMMED, GI2_LOCINI,GI2_LOCFIM,GI2_TIPLIN,GI2_PREFIX
		ORDER BY GYN.GYN_FILIAL,GI2.GI2_NUMLIN, ORD
	EndSql

					  
Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqVeic
Retorna resumo de veiculos utilizados
@type function
@author crisf
@since 04/12/2017
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
Static Function PesqVeic( cTmpVeic, cAnoMes, cDiaUtil, cSabados, cDomFer, cLinha )
	
	Local cFilGI4	:= '%'+ If(MV_PAR07 <> 3," and GI4.GI4_MSBLQL = '"+STRZERO(MV_PAR07,1)+"' ",'' )+'%'
	
	BeginSql Alias cTmpVeic
		select
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%)  AND GYN.GYN_EXTRA = 'F' THEN GQE.GQE_RECURS 
					END) AS DIAUTIL_N,	
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cSabados%) AND GYN.GYN_EXTRA = 'F' THEN GQE.GQE_RECURS
					END) AS SABADO_N,
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cDomFer%) AND GYN.GYN_EXTRA = 'F'  THEN GQE.GQE_RECURS
					END) AS DOMFER_N,
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cDiaUtil%)  AND GYN.GYN_EXTRA = 'T' THEN GQE.GQE_RECURS 
					END) AS DIAUTIL_E,
	
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cSabados%) AND GYN.GYN_EXTRA = 'T' THEN GQE.GQE_RECURS
					END) AS SABADO_E,
			COUNT(	DISTINCT CASE
						WHEN GYN.GYN_DTINI IN (%exp:cDomFer%) AND GYN.GYN_EXTRA = 'T'  THEN GQE.GQE_RECURS
					END) AS DOMFER_E
		from %Table:GIC% GIC
			INNER JOIN %Table:GYN% GYN ON
				GYN.GYN_FILIAL = GIC.GIC_FILIAL
				AND GYN.GYN_CODIGO = GIC.GIC_CODSRV
				AND GYN.GYN_TIPO = '1'
				AND GYN.%NotDel%
			INNER JOIN %Table:GQE% GQE ON
				GQE.GQE_FILIAL = GYN.GYN_FILIAL
				AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
				and GQE.GQE_TRECUR = '2'
				AND GQE.%NotDel%
			INNER JOIN %Table:GI2% GI2 ON
				GI2.GI2_FILIAL = GIC.GIC_FILIAL
				AND GI2.GI2_COD = GIC.GIC_LINHA
				AND GI2.GI2_HIST = '2'
				AND GI2.%NotDel%
			LEFT JOIN %Table:GI4% GI4 ON
				GI4.GI4_FILIAL = GI2.GI2_FILIAL
				AND GI4.GI4_LINHA = GI2.GI2_COD
				AND GI4.GI4_LOCORI = GIC.GIC_LOCORI
				AND GI4.GI4_LOCDES = GIC.GIC_LOCDES
				AND GI4.GI4_HIST = '2'
				%exp:cFilGI4%
				AND GI4.%NotDel%
		WHERE
			GIC.GIC_FILIAL = %xFilial:GIC%
			AND GIC.GIC_LINHA = %Exp:cLinha%
			AND SUBSTRING(GIC.GIC_DTVIAG, 1, 6) = %Exp:cAnoMes%
			AND ((GIC.GIC_TIPO IN ('I','T','E','M') AND GIC.GIC_STATUS IN ('V','E','T')
			AND GIC.GIC_CHVBPE = '') 
			OR (GIC.GIC_TIPO IN ('P','W') AND GIC.GIC_STATUS = 'E')
			OR (GIC.GIC_CHVBPE <> '' AND GIC.GIC_STATUS = 'V'))
			AND GIC.%NotDel%

	EndSql

Return 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqGIC
(long_description)
@type function
@author crisf
@since 03/12/2017
@version 1.0
@param cTmpGIC, character, (Descrição do parâmetro)
@param aDiasPer, array, (Descrição do parâmetro)
@param cAnoMes, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*///------------------------------------------------------------------------------------------
 Static Function PesqGIC( cTmpGIC, aDiasPer, cAnoMes, cLinha )

	Local nDias		:= 0
	Local nTtDias	:= len(aDiasPer)
	Local cSelect	:= ''
	Local cFilGI2	:= ""
	Local cFilGI4	:= '%'+ If(MV_PAR07 <> 3," and GI4.GI4_MSBLQL = '"+STRZERO(MV_PAR07,1)+"' ",'' )+'%'
	
	cFilGI2	+= If(!Empty(MV_PAR05)	," and GI2.GI2_TIPLIN = '"+MV_PAR05+"' "	,'' )
	cFilGI2	+= If(MV_PAR06 <> 3		," and GI2.GI2_MSBLQL = '"+STRZERO(MV_PAR06,1)+"' "	,'' )
	cFilGI2	:= "%"+cFilGI2+"%" 	
	
	//Monta as colunas dos dias para aglutinar os valores respectivos
	For nDias	:= 1 to nTtDias

		cSelect	+=	"	COUNT((CASE SUBSTRING(GIC.GIC_DTVEND,7,2) "+CRLF
		cSelect	+=	"				WHEN '"+aDiasPer[nDias]+"' THEN GIC_BILHET "+CRLF	
		cSelect	+=	"		END)) AS  TMP_"+aDiasPer[nDias]+", "+CRLF

	Next nDias
	
	cSelect	:= "%"+cSelect+"%"

	BeginSql Alias cTmpGIC
		
		Select
			GIC.GIC_FILIAL, 
			GIC.GIC_LINHA, 
			CASE WHEN GYN.GYN_HRINI IS NULL THEN 'Não Encontrado' 
				ELSE GYN.GYN_HRINI END GYN_HRINI, 
			GYN.GYN_CODGID,
			(SELECT COUNT(DISTINCT(GQE_RECURS)) FROM %table:GIC% GIC
			 	LEFT JOIN %table:GQE% GQE ON GQE.GQE_FILIAL = GIC.GIC_FILIAL 
			 		AND GQE.GQE_VIACOD = GIC.GIC_CODSRV 
			 		AND GQE.%NotDel% 
			 WHERE
			GIC_FILIAL = %xFilial:GIC%
			AND GIC.%NotDel%
			AND SUBSTRING(GIC.GIC_DTVEND, 1, 6) = %Exp:cAnoMes%
			AND GIC_LINHA = %Exp:cLinha%
			AND GIC_CODGID = GYN.GYN_CODGID) CARRO, 			
			%Exp: cSelect %
			COUNT(GIC.GIC_BILHET)/%Exp: nTtDias % MEDIA,
			COUNT(GIC.GIC_BILHET) TOTALBILH
		From %table:GIC% GIC
			LEFT JOIN %table:GYN% GYN ON
				GYN.GYN_FILIAL = GIC.GIC_FILIAL
				AND GYN.GYN_CODIGO = GIC.GIC_CODSRV
				AND GYN.GYN_TIPO = '1'
				AND GYN.%NotDel%
			INNER JOIN %table:GI2% GI2 ON
				GI2.GI2_FILIAL = GIC.GIC_FILIAL 
				AND GI2.GI2_COD = GIC.GIC_LINHA
				AND GI2.GI2_HIST = '2'
				AND GI2.%NotDel%
				%Exp:cFilGI2%
			LEFT JOIN %table:GI4% GI4 ON
				GI4.GI4_FILIAL = GI2.GI2_FILIAL
				AND GI4.GI4_LINHA = GI2.GI2_COD
				AND GI4.GI4_LOCORI = GIC.GIC_LOCORI
				AND GI4.GI4_LOCDES = GIC.GIC_LOCDES
				AND GI4.GI4_HIST = '2'
				AND GI4.%NotDel%
				%Exp:cFilGI4%
		Where 
			GIC.GIC_FILIAL = %xFilial:GIC%
			AND GIC.GIC_LINHA = %Exp:cLinha%
			AND ((GIC.GIC_TIPO IN ('I','T','E','M') AND GIC.GIC_STATUS IN ('V','E','T')
			AND  GIC.GIC_CHVBPE = '') 
			OR (GIC.GIC_TIPO IN ('P','W') AND GIC.GIC_STATUS = 'E')
			OR (GIC.GIC_CHVBPE <> '' AND GIC.GIC_STATUS = 'V'))
			AND SUBSTRING(GIC.GIC_DTVEND, 1, 6) = %Exp:cAnoMes%
			AND GIC.%NotDel%
		GROUP BY GIC.GIC_FILIAL, GIC.GIC_LINHA, GYN.GYN_HRINI,GYN.GYN_CODGID,GIC.GIC_SENTID
		ORDER BY GIC.GIC_FILIAL, GIC.GIC_LINHA, GYN.GYN_HRINI,GIC.GIC_SENTID
		
	EndSql

Return 
