#include 'totvs.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_expostos_sip.log"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSJOBEXP

Funcao criada para processar o job de expostos do SIP

@param      cRegANS     Número de registro da operadora
@param      cAno        Ano do trimestre
@param      cTrimestre  Trimestre de reconhecimento 1,2,3 ou 4
@param      lGerRepas   Indica se ira (.T.) importar registros referentes a beneficiarios de repasse

@author timoteo.bega
@since 29/05/2018
/*/
//--------------------------------------------------------------------------------------------------
Function PLSJOBEXP(cRegANS,cTipData)
    Local cDataRef      := DTOS(LastDate(Date()))
    Local cTipProc      := "4" //Beneficiarios expostos
    Local lGerRepas	    := .F. //Indica se ira (.T.) importar registros referentes a beneficiarios de repasse
    Local cLocDigIgn    := RetLocIgn()//Lista de locais de digitacao a ignorar
    Default cRegANS     := "000000" //Codigo de registro da operadora
    Default cTipData    := "1" //1-Digitacao,2-Pagamento,3-Procedimento

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio do job PLSJOBEXP ",ARQUIVO_LOG)

    If PodeProcessar()
    
        PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio do job PLSJOBSIP ",ARQUIVO_LOG)
        PLSJOBSIP(cDataRef,cTipData,cRegANS,cTipProc,lGerRepas,cLocDigIgn)
        Sleep(15000)
    
    EndIf

    PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Término do job PLSJOBEXP ",ARQUIVO_LOG)

Return

/*
Funcao criada para definir o pergunte do schedule 
*/
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P","PLSJOBEXP",,aOrdem,""}

Return aParam

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PodeProcessar

Funcao criada para não permitir mais de um lançamento dos jobs de expostos

@return lContinua   Retorna .T. se nao encontrou o job de expostos em execução

@author timoteo.bega
@since 29/05/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PodeProcessar()
	Local aInfo		:= GetUserInfoArray()
	Local lContinua := aScan(aInfo,{ |x| AllTrim(x[5]) == "PLSIPEXP" }) == 0
Return lContinua