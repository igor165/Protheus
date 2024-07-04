#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RHIMP17.CH"

/*******************************************************************************###
***********************************************************************************
***********************************************************************************
***Funcใo..: RHIMP17.prw Autor:Leandro Drumond Data: 22/09/2013                 ***
***********************************************************************************
***Descri็ใo..:Responsแvel pela importa็ใo de Horแrios.							   ***
***********************************************************************************
***Uso........:        																   ***
***********************************************************************************
***Parโmetros.:		cFileName, caractere, nome do arquivo       	      		   ***
***********************************************************************************
***Retorno....: ${return} - ${return_description}                               ***
***********************************************************************************
***********************************************************************************
***Chamado....:                                                                 ***
**********************************************************************************/

/*/{Protheus.doc} RHIMP17
Responsแvel pela importa็ใo de Horแrios.
@author Leandro Drumond
@since 22/09/2013
@version P11
@param cFileName, character, (Descri็ใo do parโmetro)
@return ${return}, ${return_description}
/*/
User Function RHIMP17(cFileName,aRelac,oSelf)
	Local aAreas		:= {SR6->(GetArea()),SPJ->(GetArea()),SX3->(GetArea())}
	Local aLinha		:= {}
	Local aCampos		:= {}
	Local aGrvCpo		:= {}
	Local aTnoImp		:= {}
	Local aIndAux		:= {}
	Local cBuffer       := ""
	Local cEmpAux   	:= ""
	Local cFilAux    	:= ""
	Local cTnoImp		:= ""
	Local cDescErro		:= ""
	Local cTpDia		:= ""
	Local cEmpOri    	:= "##"
	Local cFilOri		:= "##"
	Local lEnvChange 		:= .F.
	Local lDeleta 		:= .T.
	Local nCount        := 0
	Local nHrTot		:= 0
	Local nX			:= 0
	Local nJ			:= 0
	Local nPos			:= 0
	Local aTabelas 	 	:= {"SR6","SPJ"}
	Local aErro 		:= {}
	Local nTamTurno		:= TamSx3('R6_TURNO')[1]
	Local aIniPad	:= {}	
	Local lExiste := .F.
	Local cChave := ''
	Local cDia := cSemana := ''
	/*Ordem dos campos no array
	01 - * - Empresa Protheus
	02 - PJ_FILIAL 	- Filial Protheus
	03 - PJ_TURNO 	- Escala
	04 - PJ_DIA		- Dia da Semana
	05 - PJ_SEMANA  - Semana
	06 - PJ_TPDIA	- Tipo de Dia
	07 - PJ_ENTRA1	- Primeira Entrada
	08 - PJ_SAIDA1	- Saida intervalo
	09 - PJ_ENTRA2 	- Retorno Intervalo
	10 - PJ_SAIDA2 	- Fim do expediente
	*/
	
	SPJ->(DbSetOrder(1))
	DbSelectArea("SPJ")
	
	FT_FUSE(cFileName)
	/*Seta tamanho da Regua*/
	U_ImpRegua(oSelf)
	FT_FGOTOP()
	
	While !FT_FEOF() .And. !lStopOnErr
		cBuffer := FT_FREADLN()
		
		/*Checa se deve parar o processamento.*/				
		U_StopProc(aErro)
		U_StopProc(aTnoImp)		
		
		aLinha := {}
		aLinha := StrTokArr2(cBuffer,"|",.T.)
		aSize(aLinha,10)
		
		cEmpAux   := aLinha[1]
		cFilAux   := aLinha[2]
		
		If !Empty(aRelac) .and. u_RhImpFil()
			cEmpAux := u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.T.) //Busca a Empresa no DE-PARA
			cFilAux	:= u_GetCodDP(aRelac,"FILIAL",aLinha[2],"FILIAL",aLinha[1],.T.,.F.) //Busca a Filial no DE-PARA
		EndIf		
		
		U_RHPREARE(cEmpAux,cFilAux,'',@cFilOri,@lEnvChange,@lExiste,"GPEA250",aTabelas,"GPE",@aErro,OemToAnsi(STR0001))
		
		if(lEnvChange)
			SR6->(DbSetOrder(1))
			SPJ->(DbSetOrder(1))
			if(cEmpOri != cEmpAux)
				lDeleta := .T.
				cEmpOri := cEmpAux
				
				/* Quando muda a empresa pode ser que a estrutura da tabela mude */
				aIniPad := InitValues()				
			endIf
		endIf
		
		If lDeleta .and. SPJ->(DbSeek(xFilial("SPJ")))
			If MsgYesNo(OemToAnsi(STR0002)) // Apaga Movimenta็ใo Anterior?
				fDelMov('SPJ')  //Exclui todos os registros
			EndIf
			lDeleta := .F.
		Else
			lDeleta := .F.
		EndIf
		
		If lExiste
		
			//Verifica existencia de DE-PARA
			If !Empty(aRelac)
				If Empty(aIndAux) //Grava a posicao dos campos que possuem DE-PARA
					aCampos := U_fGetCpoMod("RHIMP17")
					For nX := 1 to Len(aCampos)
						For nJ := 1 to Len(aRelac)
							If (nPos := (aScan(aRelac[nJ],{|x| AllTrim(x) == AllTrim(aCampos[nX,1])}))) > 0
								aAdd(aIndAux,{nX,aRelac[nJ,1]})
							EndIf 
						Next nJ
					Next nX
				EndIf
				
				For nX := 1 to Len(aIndAux)										
					aLinha[aIndAux[nX,1]] := u_GetCodDP(aRelac,aCampos[aIndAux[nX,1],1],aLinha[aIndAux[nX,1]],aIndAux[nX,2]) //Busca DE-PARA					
				Next nX
			EndIf		

			cTnoImp	:=  PadR(aLinha[3],nTamTurno)
			U_IncRuler(OemToAnsi(STR0001),cTnoImp + AllTrim(Str(Val(aLinha[4])+1)),cStart,.F.,,oSelf)		
			
			If !(SR6->(DbSeek(xFilial("SR6")+cTnoImp)))
				If !Empty(aTnoImp)
					If aScan(aTnoImp,  { |x|  X[1]+X[2]+X[3] == cEmpAux + cFilAux + cTnoImp }) == 0
						aAdd(aTnoImp, {cEmpAux,cFilAux,cTnoImp})
					EndIf
				Else
					aAdd(aTnoImp,{cEmpAux,cFilAux,cTnoImp})
				EndIf
				FT_FSKIP()
				Loop
			EndIf
			
			nHrTotal	:= SomaHoras(SubHoras( aLinha[8] , aLinha[7] ) , SubHoras( aLinha[10] , aLinha[9] ) )
			cTpDia		:= fConvTpDia(aLinha[6])
			
			cDia := If (oSelf <> Nil,AllTrim(Str(Val(aLinha[4]))),AllTrim(Str(Val(aLinha[4])+1))) //No logix o domingo eh "0" e o sabado "6", enquanto no Protheus eh "1" e "7" respectivamente.
			cSemana := StrZero(Val(aLinha[5]),2)
			//PJ_FILIAL+PJ_TURNO+PJ_SEMANA+PJ_DIA 
			cChave := xFilial('SPJ',SR6->R6_FILIAL)
			cChave += SR6->R6_TURNO + cSemana + cDia			
			
			RecLock('SPJ',!(SPJ->(dbSeek(cChave))))
			
			SPJ->PJ_FILIAL 	:= xFilial('SPJ',SR6->R6_FILIAL)
			SPJ->PJ_TURNO 	:= SR6->R6_TURNO
			SPJ->PJ_DIA 		:= cDia
			SPJ->PJ_SEMANA 	:= cSemana
			SPJ->PJ_TPDIA 	:= cTpDia
			SPJ->PJ_ENTRA1 	:= U_VldValue(aLinha[07])
			SPJ->PJ_SAIDA1 	:= U_VldValue(aLinha[08]) 
			SPJ->PJ_ENTRA2 	:= U_VldValue(aLinha[09])
			SPJ->PJ_SAIDA2 	:= U_VldValue(aLinha[10])
			SPJ->PJ_HRTOTAL	:= nHrTotal
			SPJ->PJ_HORMENO	:= 5
			SPJ->PJ_HORMAIS	:= 5
			SPJ->PJ_TPEXT	:= If(cTpDia == "C","3",(If(cTpDia=="D","2","1")))
			SPJ->PJ_TPEXTN 	:= If(cTpDia == "C","7",(If(cTpDia=="D","6","5")))
			
			aEval(aIniPad,{|x|SPJ->&(x[1]) := InitPad(x[2])})
			
			SPJ->(MsUnLock())			
		Else
			U_IncRuler(OemToAnsi(STR0001),aLinha[3] + AllTrim(Str(Val(aLinha[4])+1)),cStart,.T.,,oSelf)		
		EndIf		
		
		FT_FSKIP()	
	EndDo
	FT_FUSE()	
	
	If !Empty(aTnoImp)
		aSort( aTnoImp ,,, { |x,y| x[1]+x[2]+X[3] < y[1]+Y[2]+Y[3] } )		
		aEval(aTnoImp,{|x|aAdd(aErro,'['+ x[1] + '/' + x[2] + '/'+ x[3] + ']' + OemToAnsi(STR0001))})		
	EndIf
	
	U_RIM01ERR(aErro)
	aSize(aTnoImp,0)
	aSize(aErro,0)
	aEval(aAreas,{|x|RestArea(x)})
	aSize(aAreas,0)
	aAreas := Nil
Return (.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณInitValues บAutor  ณLeandro Drumond    บ Data ณ  22/09/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava os dados na tabela SPJ.      			              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function InitValues()
	Local aArea	:= SX3->(GetArea())
	Local cCpoAtu	:= ''
	Local aIniPad	:= {}		
	
	/*Campos que nao devem utilizar inicializador padrao*/
	cCpoAtu := "PJ_FILIAL*PJ_TURNO*PJ_DIA*PJ_TPDIA*PJ_ENTRA1*PJ_ENTRA2*PJ_SAIDA1*PJ_SAIDA2*"
	cCpoAtu += "PJ_HRTOTAL*PJ_HORMENO*PJ_HORMAIS*PJ_TPEXTN*PJ_TPEXT" 
	
	SX3->(DbSetOrder(1))
	SX3->(dbSeek('SPJ'))	
	
	While !SX3->(EOF()) .And. (SX3->X3_ARQUIVO == 'SPJ')
		If !(SX3->X3_CAMPO $ cCpoAtu) .and. X3USO(SX3->X3_USADO) .and. !Empty(SX3->X3_RELACAO)
			aAdd(aIniPad,{AllTrim(SX3->X3_CAMPO),SX3->X3_RELACAO})
		EndIf
		SX3->(DbSkip())
	EndDo
	
	RestArea(aArea)	
Return (aIniPad)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfDelMov   บAutor  ณLeandro Drumond     บ Data ณ  22/12/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณApaga os dados da SRD.			                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDelMov(cAlias)
	Local cQuery := ''
	
	cQuery := " DELETE FROM " + InitSqlName(cAlias) + " "
	
	TcSqlExec( cQuery )
	
	TcRefresh( InitSqlName(cAlias) )
	
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณfConvTpDiaบAutor  ณLeandro Drumond     บ Data ณ  20/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica qual o tipo de dia.		                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fConvTpDia(cTipoDia)
	Local cRet := ""
	
	Do Case
	Case cTipoDia == "N"
		cRet := "S"
	Case cTipoDia == "C"
		cRet := "C"
	Case cTipoDia == "F"
		cRet := "N"
	Case cTipoDia == "R"
		cRet := "D"
	EndCase
	
Return cRet
