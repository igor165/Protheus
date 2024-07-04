#Include "Protheus.ch"
#Include "apWebSrv.ch"
#Include "WsIntRMSolum.ch"


#Define DESCRIP STR0001 //"Retorna a versão do Protheus sendo:<br><br>Versão.Release.Funcionalidade<br><br>Exemplo:<br>10.13.2 - Versão 10 Release 1.3 com suporte a rateio na solicitação de compra e no pedido de compra.<br>11.07.0 - Versão 11 Release 7 sem suporte a rateio.<br><br>Funcionalidade:<br>0 - sem suporte a rateio;<br>2 - com suporte a rateio na solicitação de compra e no pedido de compra;<br>3 - com suporte a rateio na solicitação de armazém, solicitação de compra e no pedido de compra."

//-------------------------------------------------------------------
/*/{Protheus.doc} stSource
Estrutura para armazenar o nome e data do fonte da integração Protheus
 x RM Solum (TOTVS Obras e Projetos)

@author  Mateus Gustavo de Freitas e Silva
@version P11 R7
@since   09/04/2012
/*/
//-------------------------------------------------------------------
WsStruct stSource
   WsData sDate       as String
   WsData sSource     as String
   WsData sLatestDate as String
   WsData sIssue      as String
EndWsStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} stResult
Estrutura para armazenar a versão do Protheus e os fontes da integração
 Protheus x RM Solum (TOTVS Obras e Projetos)

@author  Mateus Gustavo de Freitas e Silva
@version P11 R7
@since   09/04/2012
/*/
//-------------------------------------------------------------------
WsStruct stResult
   WsData aSources as Array Of stSource
   WsData sVersion as          String
EndWsStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} WSINTRMSOLUM
WebService para checar a versão do Protheus e dos fontes da integração
 Protheus x RM Solum (TOTVS Obras e Projetos)

@author  Mateus Gustavo de Freitas e Silva
@version P11 R7
@since   09/04/2012
/*/
//-------------------------------------------------------------------
WsService WSINTRMSOLUM DESCRIPTION STR0002 /*"WebService para conferência de funcionalidades da integração Protheus x RM Solum (TOTVS Obras e Projetos)"*/ NameSpace "http://webservices.totvs.com.br/wsintrmsolum.apw"
   WsData Version as String
   WsData Result  as stResult

   WsMethod getVersion Description DESCRIP
EndWsService

//-------------------------------------------------------------------
/*/{Protheus.doc} getVersion
Método que recebe a versão do RM e retorna a versão do Protheus com os
 fontes da integração  Protheus x RM Solum (TOTVS Obras e Projetos)

@param   Version Versão do RM

@author  Mateus Gustavo de Freitas e Silva
@version P11 R7
@since   09/04/2012

@return  Result Retorna a versão do Protheus sendo:

Versão.Release.Funcionalidade

Exemplo:
10.13.2 - Versão 10 Release 1.3 com suporte a rateio na solicitação de compra e no pedido de compra.
11.07.0 - Versão 11 Release 7 sem suporte a rateio.

Funcionalidade:
0 - sem suporte a rateio;
2 - com suporte a rateio na solicitação de compra e no pedido de compra;
3 - com suporte a rateio na solicitação de armazém, solicitação de compra e no pedido de compra.
/*/
//-------------------------------------------------------------------
WsMethod getVersion WsReceive Version WsSend Result WsService WSINTRMSOLUM
   Local aFontes   := {"PMSXSOLUM.PRW", "HHSETTRGRS.PRX", "PMSWMT105.PRW", "PMSWMT110.PRW", "PMSWMT120.PRW", "PMSWMT410.PRW", "PMSWFI040.PRW", "PMSWFI050.PRW", "PMSWFI850.PRW", "WSINTRMSOLUM.PRW"}
   Local aDatas    := {"22/05/2013", "11/11/2011", "09/07/2013", "11/04/2013", "12/07/13", "01/10/2012", "30/07/2012", "10/07/2012", "", "17/07/2013"}
   Local aChamados := {"THH095", "TDXYI0", "THLUKI", "TGJE56", "TGVQVY", "TEUIM0", "TEZCRD", "TENOF3", "", "THPAS3"}
   Local oFonte    := Nil
   Local nI        := 0
   Local cVersao   := "12"
   Local cFuncion  := "0"

   For nI := 1 To Len(aFontes)
      oFonte := WSClassNew("stSource")
      aAdd(Self:Result:aSources, oFonte)

      If Len(GetAPOInfo(aFontes[nI])) >= 4
         Self:Result:aSources[nI]:sDate   := dToC(GetAPOInfo(aFontes[nI])[4])
      Else
         Self:Result:aSources[nI]:sDate   := STR0003 //"Fonte não encontrado!"
      EndIf

      Self:Result:aSources[nI]:sSource     := aFontes[nI]
      Self:Result:aSources[nI]:sLatestDate := aDatas[nI]
      Self:Result:aSources[nI]:sIssue      := aChamados[nI]
   Next nI

   // Data da liberação do rateio de projeto/tarefa e centro de custo para o cliente piloto Ponto Forte
   If Len(GetAPOInfo("PMSXSOLUM.PRW")) >= 4 .And. Len(GetAPOInfo("PMSWMT105.PRW")) >= 4 .And. Len(GetAPOInfo("PMSWMT110.PRW")) >= 4 .And. Len(GetAPOInfo("PMSWMT120.PRW")) >= 4
      If GetAPOInfo("PMSXSOLUM.PRW")[4] >= CTOD("06/02/13") .And. GetAPOInfo("PMSWMT105.PRW")[4] >= CTOD("09/07/13") .And. GetAPOInfo("PMSWMT110.PRW")[4] >= CTOD("15/01/13") .And. GetAPOInfo("PMSWMT120.PRW")[4] >= CTOD("15/01/13")
         cFuncion := "3" //Rateio de projeto/tarefa e centro de custo na SA, SC e PC
      ElseIf GetAPOInfo("PMSXSOLUM.PRW")[4] >= CTOD("06/02/13") .And. GetAPOInfo("PMSWMT105.PRW")[4] >= CTOD("07/02/13") .And. GetAPOInfo("PMSWMT110.PRW")[4] >= CTOD("15/01/13") .And. GetAPOInfo("PMSWMT120.PRW")[4] >= CTOD("15/01/13")
         cFuncion := "2" //Rateio de projeto/tarefa e centro de custo na SC e PC
      EndIf
   EndIf

   Self:Result:sVersion := cVersao + "." + PadL(StrTran(SubStr(GetRpoRelease(), 2), ".", ""), 2, "0") + "." + cFuncion
Return .T.

// função para localização do fonte
Function WSINTRMSOLUM()
return