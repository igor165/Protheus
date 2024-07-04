#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONA480A.CH"

/*/{Protheus.doc} PONA480A
Rotina de Scheduler para buscar os dados do Dashboard RH e enviar e-mail.
@author Marco Nakazawa
@since 28/07/2022
@Type Function
/*/
Function PONA480A()
Local oClient
Local oJson
Local dData			:= Date()
Local cDia			:= Day2Str(dData)
Local cMes			:= Month2Str(dData)
Local cAno			:= Year2Str(dData)
Local cPerg 		:= "PNA480A"
Local lExistPerg 	:= fExistPerg(cPerg)
Local cLogPatch		:= GetSrvProfString("Startpath","")
Local cURLRest		:= SuperGetMV("MV_PONREST",.F.,"") 
Local cGpeMail		:= SuperGetMV("MV_GPEMAIL",.F.,"")
Local cRelausr		:= SuperGetMV("MV_RELAUSR",.F.,"")
Local cData			:= ""
Local cQryParams	:= ""
Local cDataIni		:= ""
Local cDataFim		:= ""
Local cDtIniFilt	:= ""
Local cDtFimFilt	:= ""
Local cFilFilt		:= ""
Local cFilHtml		:= ""
Local cMsg			:= ""
Local cDtHrAtual	:= ""
Local cEmail		:= ""
Local cHoraAtual	:= Time()
Local cTotFunc		:= cValToChar(0)
Local cPonCompl		:= cValToChar(0)
Local cPonIncomp	:= cValToChar(0)
Local cSemMarc		:= cValToChar(0)
Local cTotClkIn		:= cValToChar(0)
Local cTotInteg		:= cValToChar(0)
Local cTotToIntg	:= cValToChar(0)
Local cSemNsr		:= cValToChar(0)
Local aURLApi		:= {"/api/rh/v1/DbHrAttendanceControl","/api/rh/v1/DbHrClockin"}
Local aHeader		:= {"Accept: application/json","content-type: application/json","charset: UTF-8"}
Local lSchedule		:= IsBlind()
Local nI			:= 0
Local nPeriodo		:= 0
Local nQtdDias		:= 0
Local nDiasSem		:= Dow(Date())

If lExistPerg .And. !Empty(cURLRest) .And. lSchedule .And. (!Empty(cGpeMail) .Or. !Empty(cRelausr))
	cFilFilt 	:= mv_par01
	nPeriodo	:= mv_par02
	nQtdDias	:= mv_par03

	cDtHrAtual := SubStr(cHoraAtual,1,5) + " " + cDia + "/" + cMes + "/" + cAno

	If !Empty(cGpeMail)
		cEmail := cGpeMail
	Else
		cEmail := cRelausr
	EndIf

	If Empty(cFilFilt)
		cFilFilt := "todas"
	Else
		cFilHtml := cFilFilt
		cFilFilt := StrTran(cFilFilt," ","%20")
	EndIf
	
	If nPeriodo == 1 // Mensal
		cDataIni	:= "01/" + cMes + "/" + cAno
		cDataFim	:= cDia + "/" + cMes + "/" + cAno
		cDtIniFilt	:= cAno + "-" + cMes + "-01"
		cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
	ElseIf nPeriodo == 2 // Semanal
		cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
		cDataFim	:= cDia + "/" + cMes + "/" + cAno

		If nDiasSem <> 2
			If nDiasSem == 1
				dData := dData - 6
			Else
				dData := dData - (nDiasSem - 2)
			EndIf

			cDia		:= Day2Str(dData)
			cMes		:= Month2Str(dData)
			cAno		:= Year2Str(dData)
			cDataIni	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
		Else
			cDataIni	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
		Endif
	ElseIf nPeriodo == 3 // Quinzenal
		If Val(Day2Str(cDia)) > 15
			cDataIni	:= "16/" + cMes + "/" + cAno
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + "16"
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
		Else
			cDataIni	:= "01/" + cMes + "/" + cAno
			cDataFim	:= cDia + "/" + cMes + "/" + cAno
			cDtIniFilt	:= cAno + "-" + cMes + "-" + "01"
			cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia
		EndIf
	ElseIf nPeriodo == 4 // Qtde Dias
		cDataFim	:= cDia + "/" + cMes + "/" + cAno
		cDtFimFilt	:= cAno + "-" + cMes + "-" + cDia

		If nQtdDias > 60
			nQtdDias := 60
		EndIf

		dData	:= DaySub(dData,nQtdDias)
		cDia	:= Day2Str(dData)
		cMes	:= Month2Str(dData)
		cAno	:= Year2Str(dData)

		cDataIni	:= cDia + "/" + cMes + "/" + cAno
		cDtIniFilt	:= cAno + "-" + cMes + "-" + cDia
	EndIf

	cQryParams := "?startDate=" + cDtIniFilt + "&endDate=" + cDtFimFilt + "&filial=" + cFilFilt

	If cFilFilt == "todas"
		cFilHtml := "Todos"
	EndIf

	// Configuração para consumir as APIs
	oClient := FwRest():New(cURLRest)
	
	For nI := 1 To Len(aURLApi)
		oClient:SetPath(aURLApi[nI] + cQryParams)
		If oClient:Get(aHeader)
			oJson := JsonObject():New()
			oJson:fromJson(oClient:GetResult())

			If "DbHrAttendanceControl" $ aURLApi[nI]
				cTotFunc	:= cValToChar(oJson["TotalEmployees"])
				cPonCompl	:= cValToChar(oJson["ClockMarkingsComplete"])
				cPonIncomp	:= cValToChar(oJson["ClockMarkingsIncomplete"])
				cSemMarc	:= cValToChar(oJson["WithoutClockMarkings"])
			ElseIf "DbHrClockin" $ aURLApi[nI]
				cTotClkIn	:= cValToChar(oJson["TotalClockMarkings"])
				cTotInteg	:= cValToChar(oJson["TotalIntegrated"])
				cTotToIntg	:= cValToChar(oJson["TotalToBeIntegrated"])
				cSemNsr		:= cValToChar(oJson["TotalWhitoutNSR"])
			EndIf
		EndIf
	Next

	BeginContent var cHtml
		<!DOCTYPE html>
		<html>
			<head>
				<style type='text/css'>
					.title{
						font-family: Roboto-Condensed-Light,sans-serif;
						font-style: normal;
						font-weight: 200;
						font-size: 25px;
						line-height: 55px;
						color: #1D2426;
						vertical-align: bottom;
						width: 89%;
						display: inline-block;
					}
					.lastUpdate {
						font-family: Roboto,sans-serif;
						font-style: normal;
						font-weight: 400;
						font-size: 14px;
						line-height: 24px;
						text-align: left;
						color: #4A5C60;
						white-space: nowrap;
						vertical-align: bottom;
						width: 11%;
					}
					.lastUpdateDate {
						font-family: Roboto,sans-serif;
						font-style: normal;
						font-weight: 700;
						font-size: 14px;
						line-height: 24px;
						text-align: left;
						color: #4A5C60;
						white-space: nowrap;
						vertical-align: bottom;
					}
					.filters {
						white-space: nowrap;
						font-family: Roboto-Bold,sans-serif;
						font-size: 14px;
						line-height: 24px;
						color: #4a5c60;
					}
					.inputFilter { 
						padding-left: 8px;
						margin-top: 5px;
						margin-right: 12px;
						text-align: left;
						height: 34.5px;
						width: 150px;
						border: 1px solid #D3D3D3;
						border-radius: 3px;
					}
					.inputRefresh {
						border: 1px solid #0C9ABE;
						margin-top: 5px;
						border-radius: 3px;
						margin-right: 4px;
						font-weight: bold;
						text-align: center;
						height: 34.5px;
						width: 90px;
						color: #0c9abe;
					}
					.inputEmail {
						border: 1px solid #0C9ABE;
						margin-top: 5px;
						border-radius: 3px;
						font-weight: bold;
						text-align: center;
						height: 34.5px;
						width: 125px;
						color: #0c9abe;
					}
					.indicators {
						font-family:Roboto-Condensed-Light,sans-serif;
						height: 80px;
						padding: 8px;
						font-size: 24px;
						line-height: 32px;
						align-items: center;
						color: #374548;
					}
					.alert {
						font-family:Roboto-Condensed-Light,sans-serif;
						font-size: 10px;
						color: #1D2426;
						border-radius: 3px;
						display: inline-block;
						float: right;
						margin-right: 25px;
						margin-top: 10px;
						padding: 5px;
					}
					tableCards { 
						border: 1px solid #000;
					}
					.divIndicators {
						display: flex;
					}
					.cardDescriptionTotal{
						font-family: Roboto,sans-serif;
						font-size: 16px;
						color: #ffffff;
						text-align: center;
						vertical-align: top;
					}
					.cardAmountTotal{
						font-family: Calibri,sans-serif;
						font-size: 50px;
						vertical-align: top;
						justify-content: center;
						flex: 1 1 auto;
						color: #ffffff;
						text-align: center;
					}
					.cardDescription{
						font-family: Roboto,sans-serif;
						font-size: 16px;
						color: #4a5c60;
						text-align: center;
						vertical-align: top;
					}
					.cardAmount{ 
						font-family: Calibri,sans-serif;
						font-size: 50px;
						color: #4a5c60;
						justify-content: center;
						flex-direction: column;
						flex: 1 1 auto;
						text-align: center;
						vertical-align: top;
					}
				</style>
			</head>
			</body>
				<div>
					<div class='title'>Dasboard</div>
					<div style='display: inline-block;'>
						<div class='lastUpdate'>%Exp:EncodeUTF8(STR0001)%</div>
						<div class='lastUpdateDate'>%Exp:cDtHrAtual%</div>
					</div>
				</div>
				<div style='height: 25px'></div>
				<div>
					<table class='filters'>
						<tr>
							<td><b>%Exp:EncodeUTF8(STR0002)%</b></td>
							<td><b>%Exp:EncodeUTF8(STR0003)%</b></td>
							<td><b>Selecione o Local</b></td>
							<td></td>
							<td></td>
						</tr>
						<tr>
							<td><input class='inputFilter'	type='text' value=%Exp:cDataIni%></td>
							<td><input class='inputFilter'	type='text' value=%Exp:cDataFim%></td>
							<td><input class='inputFilter'	type='text' value='%Exp:cFilHtml%' style='width:280px; color: #0c9abe;'></td>
							<td><input class='inputRefresh'	type='text' value='Atualizar'></td>
							<td><input class='inputEmail'	type='text' value='Enviar-Email'></td>
						</tr>
					</table>
				</div>
				<div class='indicators'>
					<p><b>%Exp:EncodeUTF8(STR0004)%</b></p>
				</div>
				<div class='divIndicators'>
					<table class='tableCards' style='border-radius: 3px; width: 300px; height:220px; background-color: #0C9ABE; color: #ffffff;'>
						<tr style='height:33%'>
							<td style='width:100%;'></td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmountTotal'>%Exp:cTotFunc%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescriptionTotal'>%Exp:EncodeUTF8(STR0005)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
							<td class='alert' style='background-color: #DAECE5;'>%Exp:STR0006%</td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmount'>%Exp:cPonCompl%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0007)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
						<td class='alert' style='background-color: #FFEACB;'>%Exp:EncodeUTF8(STR0008)%</td>
						</tr>
						<tr>
							<td class='cardAmount'>%Exp:cPonIncomp%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0009)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
						<td class='alert' style='background-color: #F6E0E0;'>%Exp:EncodeUTF8(STR0010)%</td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmount'>%Exp:cSemMarc%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0011)%</td>
						</tr>
					</table>
				</div>
				<div class='indicators'>
					<p><b>%Exp:EncodeUTF8(STR0012)%</b></p>
				</div>
				<div class='divIndicators'>
					<table class='tableCards' style='border-radius: 3px; width: 300px; height:220px; background-color: #0C9ABE; color: #ffffff;'>
						<tr style='height:33%'>
							<td style='width:100%;'></td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmountTotal'>%Exp:cTotClkIn%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescriptionTotal'>%Exp:EncodeUTF8(STR0013)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
							<td class='alert' style='background-color: #DAECE5;'>%Exp:STR0006%</td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmount'>%Exp:cTotInteg%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0014)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
						<td class='alert' style='background-color: #FFEACB;'>%Exp:EncodeUTF8(STR0008)%</td>
						</tr>
						<tr>
							<td class='cardAmount'>%Exp:cTotToIntg%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0015)%</td>
						</tr>
					</table>
					<div style='width: 15px' ></div>
					<table class='tableCards' style='border: 1px solid #D3D3D3; border-radius: 3px; width: 300px; height:220px;'>
						<tr style='height:33%'>
						<td class='alert' style='background-color: #F6E0E0;'>%Exp:EncodeUTF8(STR0010)%</td>
						</tr>
						<tr style='height:33%'>
							<td class='cardAmount'>%Exp:cSemNsr%</td>
						</tr>
						<tr style='height:33%'>
						<td class='cardDescription'>%Exp:EncodeUTF8(STR0016)%</td>
						</tr>
					</table>
				</div>	
			</body>
		</html>
	EndContent

	nHandle := fcreate(cLogPatch + "dashboard_rh.html")
	FWrite(nHandle, cHtml)
	fclose(nHandle)

	cMsg := STR0017 + cData + STR0018 + SubStr(Time(),1,5) + "."

	If gpeMail("Dashboard",cMsg,cEmail,{cLogPatch + "dashboard_rh.html"})
		Conout(OemToAnsi(STR0025)) // "E-mail com os dados do Dashboard RH foi enviado com sucesso."
	Else
		Conout(OemToAnsi(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
	EndIf
Else
	If lSchedule
		If !lExistPerg
			Conout(OemToAnsi(STR0019) + ": " + OemToAnsi(STR0020)) // "Erro de dicionário" "O grupo de perguntas PNA480A não está criado. Execute o UPPDISTR com o pacote de dicionários da expedição contínua para a criação."
		ElseIf Empty(cURLRest)
			Conout(OemToAnsi(STR0021) + ": " + OemToAnsi(STR0022)) // "Erro no parâmetro MV_PONREST." "O parâmetro MV_PONREST não está preenchido."
		ElseIf Empty(cGpeMail) .And. Empty(cRelausr)
			Conout(OemToAnsi(STR0026)) // "Falha no envio do e-mail com os dados do Dashboard RH. Verifique as configurações para o envio do e-mail."
		EndIf
	Else
		Help(,,STR0023,,STR0024,1,0) // "Erro na execução da rotina." "Esta rotina só deve ser executada pelo Scheduler."
	EndIf
EndIf
	fErase(cLogPatch + "dashboard_rh.html")
Return

/*/{Protheus.doc} fExistPerg
//Função para verificar se existe o grupo de perguntas
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function fExistPerg(cPergunte)
Local lRet	:= .F.
Local oSX1	:= FWSX1Util():New()

oSX1:AddGroup(cPergunte)
oSX1:SearchGroup()

If !Empty(oSX1:aGrupo[1,2])
	lRet:= .T.
EndIf

FreeObj(oSX1)
Return lRet

/*/{Protheus.doc} Scheddef
//Função para execução da rotina pelo Scheduler
@author marco.nakazawa
@since 25/07/2022
@version 1.0
@return NIL
@type static function
/*/
Static Function Scheddef()
Local aOrd		:= {}
Local aParam	:= {}

aParam := {	"P"			, ; // Tipo R para relatorio P para processo
			"PNA480A"	, ;	// Pergunte do relatorio, caso nao use passar ParamDef
			""			, ; // Alias para o relatório
			aOrd		, ; // Array de ordens para o relatório
			""			}
Return aParam
