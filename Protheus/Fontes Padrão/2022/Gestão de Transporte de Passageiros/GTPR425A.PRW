#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'

Static __oCalc
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR425A
Relatório de Resumo Diário Contratos - Data de Viagem

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR425A(oCalc)
Local oReport   := nil

__oCalc := oCalc

oReport   := ReportDef()
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport   := Nil
Local oSection1 := Nil
Local oSection2 := Nil
Local oSection3 := Nil

//Ajuste no Layout para apresentar as informações
oReport := TReport():New("GTPR425A","Simulação do Ponto","",{|oReport| ReportPrint(oReport)},"Gera Simulação do Ponto",.T.)
oReport:SetLandScape(.T.)
oReport:SetTotalInLine(.F.)


oSection1:= TRSection():New(oReport,"Dados Colaborador", {"GYG"}, , .F., .T.) //

TRCell():New(oSection1,"CODIGO"     ,"G6R","Cod Colab"  ,,TamSx3('GYG_CODIGO')[1]   ) //
TRCell():New(oSection1,"NOME"       ,"G6R","Nome"       ,,TamSx3('GYG_NOME')[1]     ) //
TRCell():New(oSection1,"MATRICULA"  ,"G6R","Matricula"  ,,TamSx3('RA_MAT')[1]       ) //

oSection2:= TRSection():New(oSection1,"Dados da Marcação", {"GYG"}, , .F., .T.) //

TRCell():New(oSection2,"DTREF"      ,"","Dt Ref"        ,,10) //
TRCell():New(oSection2,"TIPODIA"    ,"","Tipo Dia"      ,,20) //
TRCell():New(oSection2,"DATA_1E"    ,"","Data 1E"       ,,10) //
TRCell():New(oSection2,"HORA_1E"    ,"","Hora 1E"       ,,05) //
TRCell():New(oSection2,"DATA_1S"    ,"","Data 1S"       ,,10) //
TRCell():New(oSection2,"HORA_1S"    ,"","Hora 1S"       ,,05) //
TRCell():New(oSection2,"DATA_2E"    ,"","Data 2E"       ,,10) //
TRCell():New(oSection2,"HORA_2E"    ,"","Hora 2E"       ,,05) //
TRCell():New(oSection2,"DATA_2S"    ,"","Data 2S"       ,,10) //
TRCell():New(oSection2,"HORA_2S"    ,"","Hora 2S"       ,,05) //
TRCell():New(oSection2,"HRSPAGAS"   ,"","Hrs Pagas"     ,,05) //
TRCell():New(oSection2,"HRSVOLANTE" ,"","Hrs Volante"   ,,05) //
TRCell():New(oSection2,"HRSFORAVOL" ,"","Hrs Fora Vol"  ,,05) //
TRCell():New(oSection2,"HRSPLANT"   ,"","Hrs Plantao"   ,,05) //
TRCell():New(oSection2,"INTERVTOT"  ,"","Interv. Tot."  ,,05) //
TRCell():New(oSection2,"INTERVPGT"  ,"","Interv. Pgt."  ,,05) //
TRCell():New(oSection2,"HREXTRAS"   ,"","Hrs Extras"    ,,05) //
TRCell():New(oSection2,"HRNEGATIV"  ,"","Hrs Negativas" ,,05) //
TRCell():New(oSection2,"HRADNOT"    ,"","Hrs Adn Not."  ,,05) //

oSection3:= TRSection():New(oSection1,"Totais", {""}, , .F., .T.) //

TRCell():New(oSection3,"HRMENSAIS"  ,"","Hrs Mensais"   ,,06) //
TRCell():New(oSection3,"HRSPAGAS"   ,"","Hrs Pagas"     ,,06) //
TRCell():New(oSection3,"HRSVOLANTE" ,"","Hrs Volante"   ,,06) //
TRCell():New(oSection3,"HRSFORAVOL" ,"","Hrs Fora Vol"  ,,06) //
TRCell():New(oSection3,"HRSPLANT"   ,"","Hrs Plantao"   ,,06) //
TRCell():New(oSection3,"INTERVTOT"  ,"","Interv. Tot."  ,,06) //
TRCell():New(oSection3,"INTERVPGT"  ,"","Interv. Pgt."  ,,06) //
TRCell():New(oSection3,"HREXTRAS"   ,"","Hrs Extras"    ,,06) //
TRCell():New(oSection3,"HRNEGATIV"  ,"","Hrs Negativas" ,,06) //
TRCell():New(oSection3,"SALDOHORAS" ,"","Saldo de Horas",,07) //
TRCell():New(oSection3,"HRADNOT"    ,"","Hrs Adn Not."  ,,06) //
TRCell():New(oSection3,"QTDDSRDISP" ,"","Qtd Dsr Disp"  ,,02) //
TRCell():New(oSection3,"QTDDSRUTIL" ,"","Qtd Dsr Util"  ,,02) //
TRCell():New(oSection3,"QTDFALTAS"  ,"","Qtd Faltas"    ,,02) //
TRCell():New(oSection3,"EXTMENOSDSR","","Ext - Dsr"     ,,06) //

oSection1:SetColSpace(1,.F.)
oSection1:SetAutoSize(.F.)

oSection2:SetColSpace(1,.F.)
oSection2:SetAutoSize(.F.)

oSection3:SetColSpace(1,.F.)
oSection3:SetAutoSize(.F.)



oSection2:Cell("DTREF"      ):lHeaderSize := .F.
oSection2:Cell("DATA_1E"    ):lHeaderSize := .F.
oSection2:Cell("DATA_1S"    ):lHeaderSize := .F.
oSection2:Cell("DATA_2E"    ):lHeaderSize := .F.
oSection2:Cell("DATA_2S"    ):lHeaderSize := .F.



Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão.

@author fabio.veiga
@since 11/07/2018
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1     := oReport:Section(1)
Local oSection2     := oSection1:Section(1)
Local oSection3     := oSection1:Section(2)

Local n1            := 0
Local nExtMenosDsr  := 0
Local oCalc         := __oCalc
Local oCalcDia      := nil

Local aTpDia	:= GTPXCBox('GQK_TPDIA')

aAdd(aTpDia,cValTochar(Len(aTpDia)+1)+'=Falta')//'=Falta'

oReport:StartPage()	

oSection1:Init()
    
oSection1:Cell("CODIGO"     ):SetValue(oCalc:cColab)  
oSection1:Cell("NOME"       ):SetValue(Posicione('GYG',1,xFilial('GYG')+oCalc:cColab ,'GYG_NOME') )  
oSection1:Cell("MATRICULA"  ):SetValue(Posicione('GYG',1,xFilial('GYG')+oCalc:cColab ,'GYG_FUNCIO'))  

oSection1:PrintLine()
oSection1:Finish()

oReport:SkipLine()

For n1  := 1 to Len(oCalc:aDias)
    oCalcDia := oCalc:aDias[n1]

    oSection2:Init()
        
    oSection2:Cell("DTREF"      ):SetValue(oCalcDia:dDtRef      ) 
    oSection2:Cell("TIPODIA"    ):SetValue(SubStr(aTpDia[Val(oCalcDia:cTpDia)],3)       ) 
    oSection2:Cell("DATA_1E"    ):SetValue(oCalcDia:dData_1E    ) 
    oSection2:Cell("HORA_1E"    ):SetValue(oCalcDia:cHora_1E    ) 
    oSection2:Cell("DATA_1S"    ):SetValue(oCalcDia:dData_1S    ) 
    oSection2:Cell("HORA_1S"    ):SetValue(oCalcDia:cHora_1S    ) 
    oSection2:Cell("DATA_2E"    ):SetValue(oCalcDia:dData_2E    ) 
    oSection2:Cell("HORA_2E"    ):SetValue(oCalcDia:cHora_2E    ) 
    oSection2:Cell("DATA_2S"    ):SetValue(oCalcDia:dData_2S    ) 
    oSection2:Cell("HORA_2S"    ):SetValue(oCalcDia:cHora_2S    ) 
    oSection2:Cell("HRSPAGAS"   ):SetValue(oCalcDia:cHrPagas    ) 
    oSection2:Cell("HRSVOLANTE" ):SetValue(oCalcDia:cHrVolante  ) 
    oSection2:Cell("HRSFORAVOL" ):SetValue(oCalcDia:cHrForaVol  ) 
    oSection2:Cell("HRSPLANT"   ):SetValue(oCalcDia:cHrPlantao  ) 
    oSection2:Cell("INTERVTOT"  ):SetValue(oCalcDia:cHrIntTot   ) 
    oSection2:Cell("INTERVPGT"  ):SetValue(oCalcDia:cHrIntPgt   ) 
    oSection2:Cell("HREXTRAS"   ):SetValue(oCalcDia:cHrExtra    ) 
    oSection2:Cell("HRNEGATIV"  ):SetValue(oCalcDia:cHrNegat    ) 
    oSection2:Cell("HRADNOT"    ):SetValue(oCalcDia:cHrAdnNot   ) 

    oSection2:PrintLine()
    
Next

oSection2:Finish()

If oCalc:nSaldoHora > 0 .and. oCalc:nDsrDisp > oCalc:nDsrUtil
    nExtMenosDsr    := oCalc:nSaldoHora - (oCalc:nHrsDia * (oCalc:nDsrDisp-oCalc:nDsrUtil) ) 
    If nExtMenosDsr < 0 //Ignorar quando negativo
        nExtMenosDsr    := 0
    Endif
Endif

oSection3:Init()
    
oSection3:Cell("HRMENSAIS"  ):SetValue(oCalc:cHrPeriodo )
oSection3:Cell("HRSPAGAS"   ):SetValue(oCalc:cHrPagas )
oSection3:Cell("HRSVOLANTE" ):SetValue(oCalc:cHrVolante )
oSection3:Cell("HRSFORAVOL" ):SetValue(oCalc:cHrForaVol )
oSection3:Cell("HRSPLANT"   ):SetValue(oCalc:cHrPlan )
oSection3:Cell("INTERVTOT"  ):SetValue(oCalc:cHrIntTot )
oSection3:Cell("INTERVPGT"  ):SetValue(oCalc:cHrIntPgt )
oSection3:Cell("HREXTRAS"   ):SetValue(oCalc:cHrExtra )
oSection3:Cell("HRNEGATIV"  ):SetValue(oCalc:cHrNegat )
oSection3:Cell("SALDOHORAS" ):SetValue(oCalc:cSaldoHora )
oSection3:Cell("HRADNOT"    ):SetValue(oCalc:cHrAdnNot )
oSection3:Cell("QTDDSRDISP" ):SetValue(oCalc:nDsrDisp )
oSection3:Cell("QTDDSRUTIL" ):SetValue(oCalc:nDsrUtil )
oSection3:Cell("QTDFALTAS"  ):SetValue(oCalc:nQtdFaltas )
oSection3:Cell("EXTMENOSDSR"):SetValue(IntToHora(nExtMenosDsr,3) )

oSection3:PrintLine()
oSection3:Finish()

Return
