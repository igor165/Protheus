#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR448
Relat�rio de Cr�ditos de ocntrato pr�-estabelecido x grupos x per�odo de cobertura
@author Oscar Zanin
@since 04/02/2022
@version P12
/*/
//-------------------------------------------------------------------
function PLSR448()
local oReport := nil
Local aPergs := {}
Local aFilter := {}
Local cMes := "  "
Local cAno := "     "

aAdd( aPergs,{ 1, "M�s Cobertura"	, cMes  , "", "", ""		, "", 50, .f.})
aAdd( aPergs,{ 1, "Ano Cobertura"	, cAno  , "", "", ""		, "", 50, .f.})

if (paramBox( aPergs,"M�s e Ano de cobertura",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSR448',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
    if !empty(afilter[1]) .AND. !empty(afilter[2])
        oReport := reportDef(aFilter)
        oReport:printDialog()
        freeObj(oReport)
    else
        MsgAlert("Necess�rio preencher os par�metros de m�s e ano")
    endif
endif

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR448
Relat�rio de Cr�ditos de ocntrato pr�-estabelecido x grupos x per�odo de cobertura
@author Oscar Zanin
@since 04/02/2022
@version P12
/*/
//-------------------------------------------------------------------
static function reportDef(aFilter)
local oReport       := nil
local oSTITULO		:= nil
Local cTexto		:= "Cr�ditos Capitation x Per�odo de cobertura x Grupo de Benefici�rios"

//objeto report
oReport := TReport():new("PLSR448",cTexto,,{|oReport| ReportPrint(oReport,aFilter[1],afilter[2],cTexto)},cTexto) //"Registro de Eventos Pagos"
oReport:setTotalInLine(.f.)
oReport:setLandscape()

//celulas da sessao oSTITULO
oSTITULO := TRSection():new(oReport, cTexto, {"TRBLIV"},,.f.,.t.)
oSTITULO:setPageBreak(.F.)
oSTITULO:setLineBreak(.T.)
oSTITULO:setHeaderPage(.T.)
oSTITULO:SetAutoSize(.T.)
oSTITULO:SetHeaderSection(.T.) 

//- Identificador do contrato
//- M�s e ano do cr�dito
//- Valor do cr�dito
//- Grupo vinculado (caso exista)
//- Identificador RDA
//- Data de pagamento

// Campos para impress�o
TRCell():new(oSTITULO,"RDA"	        ,"TRBLIV", "C�digo RDA"     , , 6)//RDA contratada
TRCell():new(oSTITULO,"CONTRATO"	,"TRBLIV", "Contrato"       , , 20)//C�digo do contrato
TRCell():new(oSTITULO,"MES"	        ,"TRBLIV", "M�s Cobertura"  , , 02)//M�s compet�ncia da cobertura
TRCell():new(oSTITULO,"ANO"	        ,"TRBLIV", "Ano Cobertura"  , , 04)//Ano compet�ncia da cobertura
TRCell():new(oSTITULO,"GRUPO"       ,"TRBLIV", "C�digo do Grupo de Benefici�rios"  , , 3)//Grupo ao qual se refere o cr�dito
TRCell():new(oSTITULO,"VALOR"	    ,"TRBLIV", "Valor Contratado", "@E 9,999,999,999.99", 14)//Valor do cr�dito gerado
TRCell():new(oSTITULO,"TITULO"	    ,"TRBLIV", "T�tulo"         , , tamSX3("BGQ_PREFIX")[1] + tamSX3("BGQ_NUMTIT")[1] + tamSX3("BGQ_PARCEL")[1] + tamSX3("BGQ_TIPTIT")[1])//N�mero do t�tulo
TRCell():new(oSTITULO,"EMISSAO"	    ,"TRBLIV", "Emiss�o"        ,"@D", 10)//Emiss�o do t�tulo
TRCell():new(oSTITULO,"BAIXA"       ,"TRBLIV", "Baixa"          ,"@D", 10)//Baixa do t�tulo
TRCell():new(oSTITULO,"DATCONT"     ,"TRBLIV", "Data Doc. Cont�bil"       ,"@D", 10)//Data documento cont�bil
TRCell():new(oSTITULO,"DOCCONT"     ,"TRBLIV", "Documento Cont�bil"       , , 15)//Documento cont�bil

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR448
Relat�rio de Cr�ditos de ocntrato pr�-estabelecido x grupos x per�odo de cobertura
@author Oscar Zanin
@since 04/02/2022
@version P12
/*/
//-------------------------------------------------------------------
static function ReportPrint(oReport,cMes,cAno,cTexto)
local oSTITULO		:= oReport:section(1)
Local dEmiss    := StoD("")
Local dBaixa    := StoD("")
Local dDocCtb   := StoD("")
Local cDocCTB   := ""

getTrbQuery(cMes,cAno)

if oReport:page() == 1
	oReport:setTitle("Movimenta��es de contrato pr�-estabelecido da compet�ncia")
endIf

oReport:onPageBreak({|| oReport:setTitle("Movimenta��es de contrato pr�-estabelecido da compet�ncia"),.T.} )

//define regua
oReport:setMeter(0)

BAU->(dbSetOrder(1))
SE2->(DbSetOrder(1))
CV3->(dbsetOrder(3))

If !TRBLIV->(EoF())
	
	TRBLIV->(DbgoTop())

	while !oReport:cancel() .and. !TRBLIV->(eof())

		oReport:incMeter()

        dEmiss    := StoD("")
        dBaixa    := StoD("")
        dDocCtb   := StoD("")
        cDocCTB   := ""

        if BAU->(MsSeek(xFilial("BAU") + TRBLIV->RDA))
            if SE2->(MsSeek(xFilial("SE2") + TRBLIV->PREFIXO + TRBLIV->NUMERO + TRBLIV->PARCELA + TRBLIV->TIPO + BAU->BAU_CODSA2 + BAU->BAU_LOJSA2))
                dEmiss    := SE2->E2_EMISSAO
                dBaixa    := SE2->E2_BAIXA
                if CV3->(MsSeek( xFilial("CV3") + "SE2" + AllTrim(Str(SE2->(Recno()))) ))
                    //Cuidado com os casos que gera o CV3 sem um CT2 pq a f�rmula retorna zero, por isso esse loop aqui
                    While !(CV3->(EoF())) .AND. xFilial("CV3") + "SE2" + AllTrim(Str(SE2->(Recno()))) == CV3->CV3_FILIAL + CV3->CV3_TABORI + AllTrim(CV3->CV3_RECORI)
                        if !empty(CV3->CV3_RECDES)
                            CT2->(dbGoTo(Val(CV3->CV3_RECDES)))
                            dDocCtb   := CT2->CT2_DATA
                            cDocCTB   := CT2->(CT2_LOTE+CT2_SBLOTE+CT2_DOC)
                            exit
                        endif
                        CV3->(dbSkip())
                    endDo
                endif
            endif
        endif
		//informacoes do titulo
		oSTITULO:init()

		oSTITULO:cell("CONTRATO"):setValue(TRBLIV->CONTRATO)
        oSTITULO:cell("MES"):setValue(TRBLIV->MES)
        oSTITULO:cell("ANO"):setValue(TRBLIV->ANO)
        oSTITULO:cell("VALOR"):setValue(TRBLIV->VALOR)
        oSTITULO:cell("GRUPO"):setValue(TRBLIV->GRUPO)
        oSTITULO:cell("RDA"):setValue(TRBLIV->RDA)
        oSTITULO:cell("TITULO"):setValue(TRBLIV->PREFIXO + TRBLIV->NUMERO + TRBLIV->PARCELA + TRBLIV->TIPO )
        oSTITULO:cell("EMISSAO"):setValue(dEmiss)
        oSTITULO:cell("BAIXA"):setValue(dBaixa)
        oSTITULO:cell("DATCONT"):setValue(dDocCtb)
        oSTITULO:cell("DOCCONT"):setValue(cDocCTB)

		TRBLIV->(dbSkip())	
		
		oSTITULO:printLine()
		oSTITULO:finish()
	EndDo

	oReport:endPage()
	
EndIf

//Fecha a tabela tempor�ria 
TRBLIV->(dbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSR448
Relat�rio de Cr�ditos de ocntrato pr�-estabelecido x grupos x per�odo de cobertura
@author Oscar Zanin
@since 04/02/2022
@version P12
/*/
//-------------------------------------------------------------------
static function getTrbQuery(cMes,cAno)
local nX	 	 	:= 0
local cQuery	 	:= ''
local aStruSQL 	 	:= {}

//Cr�dito
cQuery += " Select "
cQuery += " BGQ_IDCOPR CONTRATO, BGQ_MES MES, BGQ_ANO ANO, BGQ_VALOR VALOR, B94_CODGRU GRUPO, BGQ_CODIGO RDA, "
cQuery += " BGQ_PREFIX PREFIXO, BGQ_NUMTIT NUMERO, BGQ_PARCEL PARCELA, BGQ_TIPTIT TIPO"
cQuery += " From " + RetSqlName("BGQ") + " BGQ "
//Contrato
cQuery += " Inner Join " + RetSqlName("B8O") + " B8O "
cQuery += " On "
cQuery += " B8O_FILIAL = '" + xFilial("B8O") + "' AND "
cQuery += " B8O_IDCOPR = BGQ_IDCOPR AND "
cQuery += " B8O_CODRDA = BGQ_CODIGO AND "
cQuery += " B8O.D_E_L_E_T_ = ' ' "
//Grupo x Contrato
cQuery += " Inner Join " + RetSqlName("B94") + " B94 "
cQuery += " On "
cQuery += " B94_FILIAL = '" + xFilial("B94") + "' AND "
cQuery += " B94_IDCOPR = BGQ_IDCOPR AND "
cQuery += " B94_SEQUEN + B94_CODGRU = BGQ_IDGRP AND "
cQuery += " B94_IDCOPR = B8O_IDCOPR AND "
cQuery += " B94.D_E_L_E_T_ = ' ' "
/*
//Grupo benefici�ro
Inner Join B97T10 B97
On
B97_FILIAL = 'M SP ' AND
B97_CODIGO = B94_CODGRU AND
B97.D_E_L_E_T_ = ' '

//Benefici�rios do grupo
Inner Join B9UT10 B9U
On
B9U_FILIAL = 'M SP ' AND
B9U_CODGRU = B97_CODIGO AND
B9U.D_E_L_E_T_ = ' '
*/
cQuery += " Where "
cQuery += " BGQ_FILIAL = '" + xFilial("BGQ") + "' AND "
cQuery += " BGQ_IDCOPR <> ' ' AND "
cQuery += " BGQ_MES = '" + cMes + "' AND "
cQuery += " BGQ_ANO = '" + cAno + "' AND "
cQuery += " BGQ.D_E_L_E_T_ = ' ' "

MPSysOpenQuery( changeQuery(cQuery), 'TRBLIV' )

aStruSQL := TRBLIV->( dbStruct() )

for nX := 1 to len(aStruSQL)

	if aStruSQL[nX][2] <> "C"
		tcSetField('TRBLIV' ,aStruSQL[nX][1],aStruSQL[nX][2],aStruSQL[nX][3],aStruSQL[nX][4])
	endIf
	
next nX

return

