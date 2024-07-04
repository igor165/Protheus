#Include 'Protheus.ch'

#Define	INIT_CPO			1
#Define	INIT_CONTEUDO		2


//------------------------------------------------------------------------------
/*/{Protheus.doc} RUP_PMS()
Fun��es de compatibiliza��o e/ou convers�o de dados para as tabelas do sistema.
@sample	RUP_PMS("12", "2", "006", "007", "BRA")
@param		cVersion	- Vers�o do Protheus 
@param		cMode		- Modo de execu��o	- "1" = Por grupo de empresas / "2" =Por grupo de empresas + filial (filial completa)
@param		cRelStart	- Release de partida	- (Este seria o Release no qual o cliente est�)
@param		cRelFinish	- Release de chegada	- (Este seria o Release ao final da atualiza��o)
@param		cLocaliz	- Localiza��o (pa�s)	- Ex. "BRA"
@return	Nil
@author	Servi�os CRM
@since		28/10/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function RUP_PMS(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

    Local aArea		:=	GetArea()
    Local aAreaSX3	:=	SX3->(GetArea())

    If cVersion == '12' // Altera��o realizada ap�s a expedi��o da 12.1.27. Manter o RUP at� a finaliza��o do release 30
        If SX3->(DbSeek("AFN_QUANT "))
            If AllTrim(SX3->X3_CBOX) == "1=Sim;2=Nao" 
                RecLock("SX3")
                SX3->X3_CBOX    := ''
                SX3->X3_CBOXSPA := ''
                SX3->X3_CBOXENG := ''
                SX3->(MsUnlock())
            EndIf
        EndIf
    EndIf
	
    RestArea(aAreaSX3)
    RestArea(aArea)
Return Nil