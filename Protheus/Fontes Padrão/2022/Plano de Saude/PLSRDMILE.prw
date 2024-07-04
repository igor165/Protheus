#INCLUDE "TOTVS.CH"

/*
{Protheus.doc} PLSMILE
RdMake padrao para utilização de importacao/exportacao da rotina MILE

A declaracao do usuario deve seguir abaixa da PLSMILE

@author Alexander Santos
@since 7/04/2014
@version P11
*/
user function PLSRDMILE()
return(.t.)

/*/ Declaração de funcaoes do usuario /*/
user function MBD4VR(xA,xB)
local cRet := '0'

//valor fraciona
if len(xB)>30
	if xA == 'F'
		cRet := substr(xB,1,8)+"."+substr(xB,9,3)	
	elseIf xA == 'V'
		cRet := substr(xB,12,8)+"."+substr(xB,20,3)
	else
		cRet := substr(xB,23,8)+"."+substr(xB,31,3)
	endIf
//valor nao fracionado
else
	if xA == 'F'
		cRet := substr(xB,1,8)+"."+substr(xB,9,2)	
	elseIf xA == 'V'
		cRet := substr(xB,11,8)+"."+substr(xB,19,2)
	else
		cRet := substr(xB,21,8)+"."+substr(xB,29,2)	
	endIf
endif

return(cRet)


//Pre execucao
user function PLSMPREE()
local aInLay		:= paramixb[1]//Com ou sem interface e o nome do layout
local aInfo		:= paramixb[2]//Vetor com informacoes adicionais
local aDef		:= paramixb[3]//Vetor com definicoes do layout
local oModel		:= paramixb[4]//Modelo de dados preenchido

return(oModel)

//Pos execucao
user function PLSMPOSE()
local aInLay		:= paramixb[1]//Com ou sem interface e o nome do layout
local aInfo		:= paramixb[2]//Vetor com informacoes adicionais
local aDef		:= paramixb[3]//Vetor com definicoes do layout
local oModel		:= paramixb[4]//Modelo de dados preenchido
local lErrImp		:= paramixb[5]//Erro na importacao .t. = erro na importacao, .f. nao tem erro

return()

//Trata dados
user function PLSMTRAD()
local aInLay		:= paramixb[1]//Com ou sem interface e o nome do layout
local aInfo		:= paramixb[2]//Vetor com informacoes adicionais
local aDef		:= paramixb[3]//Vetor com definicoes do layout
local oModel		:= paramixb[4]//Modelo de dados preenchido
local nPos		:= 0
local nI			:= 0
local dDatVIni	:= stod('')
local dDatVFin	:= StoD('')
local cTable		:= ''
local cLayout		:= aInLay[2]
local oModelD		:= nil
local aStruct		:= aInfo[4]
local aSaveLine 	:= fwSaveRows()

do case
	case cLayout != 'CBHPM'
		if (nPos := ascan(aStruct,{|x| x[4] == 'BD4_VIGINI'}) ) > 0
			cIdModel 	:= aStruct[nPos,1]
			dDatVIni 	:= aStruct[nPos,5]
			dDatVFin	:= dDatVIni - 1
			cTable		:= aStruct[nPos,6]
			oModelD  	:= oModel:getModel(cIdModel)
			
			if oModelD:isInserted() .and. oModelD:length()>1
				
				for nI:=1 to oModelD:length()
					
					oModelD:goLine(nI)
					
					if !empty(oModelD:getValue('BD4_VIGINI')) .and. empty(oModelD:getValue('BD4_VIGFIM')) 

						//necessario para validacao de campo
						BD4->(dbGoTo(oModelD:getDataid(nI)))
						regToMemory(cTable,.f.)

						oModelD:setValue('BD4_VIGFIM',dDatVFin)
					endIf
				
				next
				
			endIf
		endIf
endCase
	
fwRestRows(aSaveLine)

return(oModel)

//Valida Operacao
user function PLSMVALO()
local aInLay		:= paramixb[1]//Com ou sem interface e o nome do layout
local aInfo		:= paramixb[2]//Vetor com informacoes adicionais
local aDef		:= paramixb[3]//Vetor com definicoes do layout
local oModel		:= paramixb[4]//Modelo de dados preenchido
local nI,nY		:= 0
local nPos		:= 0
local nIniArray	:= 0
local cLayout		:= aInLay[2]
local cTable		:= 'BD4'
local nValRef		:= 0
local cField		:= ''
local xConteudo	:= ''
local cUnidade	:= ''
local oModelD		:= nil
local aMatLine	:= aInfo[3]
local aStruct		:= aInfo[4]
local aAux		:= {}
local aSaveLine 	:= fwSaveRows()
local lRet		:= .t.

do case
	//validacao CBHPM e AMB (AMB9092 ou AMB9699)
	case cLayout == 'CBHPM' .or. cLayout == 'AMB9092' .or. cLayout == 'AMB9699'
		//posiciona no primeiro registro da tabela
		if ( nIniArray := ascan(aStruct,{|x| x[6] == cTable}) ) > 0
		
			oModelD := oModel:getModel(aStruct[nIniArray,1])
			
			if cLayout == 'CBHPM'
				
				for nI:=6 to len(aMatLine)
					if ( nValRef := val(strTran(alltrim(aMatLine[nI]),',','.')) ) != 0
						do case
							case nI==6
								cUnidade = 'UCO'
							case nI==7
								cUnidade =	 'AUX'
							case nI==8
								cUnidade =	 'PAP'
							case nI==9
								cUnidade =	 'FIL'
							otherWise
								loop	
						endCase
						
						aadd(aAux,{cUnidade,nValRef})
					endIf
				next
				
			elseIf cLayout == 'AMB9092' .or. cLayout == 'AMB9699'
				
				for nI:=4 to len(aMatLine)
					if ( nValRef := val(strTran(alltrim(aMatLine[nI]),',','.')) ) != 0
						do case
							case nI==4
								cUnidade = iif(cLayout == 'AMB9699','COR','COP')
							case nI==5
								cUnidade =	 'AUX'
							case nI==6
								cUnidade =	 iif(cLayout == 'AMB9699','PAR','PA')
							case nI==7
								cUnidade =	 'FIL'
							otherWise
								loop	
						endCase
						
						aadd(aAux,{cUnidade,nValRef})
					endIf
				next
			endIf

			//alimenta o modelo
			for nI:=1 to len(aAux)
		
				cUnidade 	:= aAux[nI,1]
				nValRef 	:= aAux[nI,2]
						
				if !oModelD:isEmpty()						
					oModelD:addLine()
				endIf	
				if (lRet := oModelD:isInserted())
				
					for nY:=nIniArray to len(aStruct) 	
						cField		:= aStruct[nY,4]
						xConteudo	:= aStruct[nY,5]
						
						if cField == "BD4_CODIGO" 
							xConteudo	:= cUnidade
						elseIf cField == "BD4_VALREF"
							xConteudo	:= nValRef
						elseIf cField == "BD4_PORMED"
							xConteudo	:= ''
						endIf 
						
						if !(lRet := oModelD:setValue(cField, xConteudo))
							exit
						endIf	
					next	
				endIf
				
				if lRet
					if !(lRet := oModel:vldData())
						exit
					endIf	
				endIf
			next
		endIf	
endCase

fwRestRows(aSaveLine)

return(lRet)

//Valida linha a linha apos extração de conteudo
user function PLSMPEXE()
local aReg 		:= paramixb[1]//{cIdModel,cUnico,cType,cField,xConteudo,cTable,nIni,nFim,lSeparador,oModel,lRet}
local lRet 		:= .t.
local cIdModel	:= ''
local oModel		:= ''
local oModelD		:= nil
local nValRef		:= 0
local nPos		:= 0
local nI			:= 0

if len(aReg)>0 .and. len(aReg[1])>3 
	if (nPos := aScan(aReg,{|x| x[4] == 'BD4_VALREF'}))>0
	
		cIdModel	:= aReg[nPos,1]
		oModel		:= aReg[nPos,10]
		
		oModel:activate()
		
		oModelD := oModel:getModel(cIdModel)
		
		for nI:=1 to oModelD:length()
			oModelD:goLine(nI)
			if !empty(oModelD:getValue('BD4_VIGINI')) .and. empty(oModelD:getValue('BD4_VIGFIM'))
				nValRef := oModelD:getValue('BD4_VALREF')
			endIf	
		next
	
		lRet := aReg[nPos,5] > 0 .and. nValRef <> aReg[nPos,5]
		
		oModel:deActivate()
	endIf
endIf

return(lRet)

//valida linha do registro pai (aborta inclusao do registro pai e filho) caso necessario para validar incluisao do pai conforme dados do filho.
user function PLSMPMES()
local aReg := paramixb[1]//Conteudo da linha com campos
local nPos := 0
local lRet := .t.

if (nPos := aScan(aReg,{|x| x[1] == '__VALREF'}))>0
	lRet := aReg[nPos,2] > 0
endIf	

return(lRet)


//dados da movimentacao (contas medicas)
user function PLMOVMI()
local nI			:= 0
local cChaveReg 	:= ''
local cChaveDad 	:= ''
local cErro		:= ''
local aDadCon		:= paramixb[1] //Dados no canal
local aDados		:= {}
local aItens		:= {}
local aBD7		:= {}
local aIte		:= {}
local aMatInfo	:= {}
local aCriticas	:= {}

if Type('___aMatBWT') == 'U'
	BWT->(dbGoTop())     
	BWT->(dbSeek(Xfilial("BWT")))
	
	___aMatBWT := {}
	while !BWT->(eof()) .and. xFilial("BWT") == BWT->BWT_FILIAL
		aadd(___aMatBWT,{ BWT->BWT_CODOPE,BWT->BWT_CODPAR,BWT->BWT_CODEDI } )
	BWT->(dbSkip())
	endDo
	
endIf


for nI:=1 to len(aDadCon)

	if aDadCon[nI,1] == 'CAB'
		aDados := aDadCon[nI,2]
	else

		aIte 	:= aDadCon[nI,2]
		cPosPro:= PLSRETDAD(aIte,'POSPRO','')
		
		if !empty(cPosPro)
		
			cChaveReg	:= PLSRETDAD(aIte,"SEQMOV",'')+PLSRETDAD(aIte,"CODPAD",'')+PLSRETDAD(aIte,"CODPRO",'')
			
			if cChaveReg != cChaveDad
				
				if len(aBD7)>0
					aadd(aAuxIte,{"REGBD7",aBD7})
					aadd(aItens,aAuxIte)
					
					aBD7 := {}
				endIf	

				cChaveDad	:= cChaveReg
				aAuxIte 	:= aIte
			endIf
			
			if cChaveReg == cChaveDad 
				if (nPos := aScan( ___aMatBWT,{ |x| x[3] == cPosPro })) > 0
				
					aadd( aBD7,{ 	___aMatBWT[nPos,2],;				//01
									PLSRETDAD(aIte,"CODUNM",''),;	//02
									PLSRETDAD(aIte,"NLANC",''),;	//03
									PLSRETDAD(aIte,"REFTDE",0),;	//04
									PLSRETDAD(aIte,"UNITDE",''),;	//05
									PLSRETDAD(aIte,"PERPRO",0),;	//06
									PLSRETDAD(aIte,"SIGLA",''),;	//07
									PLSRETDAD(aIte,"REGPRE",''),;	//08
									PLSRETDAD(aIte,"ESTPRE",''),;	//09
									PLSRETDAD(aIte,"CDPFPR",''),;	//10
									PLSRETDAD(aIte,"CDRDAC",''),;	//11
									PLSRETDAD(aIte,"NMRDAC",''),; 	//12
									PLSRETDAD(aIte,"EPEXEC",''),;	//13
									PLSRETDAD(aIte,"VLGLOC",0),; 	//14
									PLSRETDAD(aIte,"VLPAGC",0),; 	//15
									PLSRETDAD(aIte,"VLTPFC",0),; 	//16
									PLSRETDAD(aIte,"VLAPRC",0) })	//17
				endIf
			endIf
		else
			if len(aBD7)>0
				aadd(aAuxIte,{"REGBD7",aBD7})
				aadd(aItens,aAuxIte)
				aBD7 := {}
			else
				aadd(aItens,aIte)
			endIf	
		endIf
		
	endIf	
next

if len(aBD7)>0
	aadd(aAuxIte,{"REGBD7",aBD7})
	aadd(aItens,aAuxIte)
endIf	


aRet := PLSXAUTP(aDados,aItens)

//Caso queira retornar criticas ou informacoes do XMOVs
aCriticas 	:= aRet[4]

for nI:=1 to len(aCriticas)
	cErro += allTrim(aCriticas[nI,1]) + ' - ' + allTrim(aCriticas[nI,2])+chr(13)
next

if !aRet[1]
	aMatInfo := aRet[10]
	
	for nI:=1 to len(aMatInfo)
		cErro += allTrim(aMatInfo[nI,1]) + iif(upper(aMatInfo[nI,2])<>'NIL', ' - ' + allTrim(aMatInfo[nI,2]),'')+chr(13)
	next
endIf

if !empty(cErro)
	cErro := 'Necessário analisar as inconsistências do arquivo:'+chr(13)+cErro
endIf

return(cErro)


//Valida Operacao na movimentacao (contas medicas)
user function PLMOVAO()
local aInfo		:= paramixb[2]//Vetor com registro da linha
local aDadCon		:= aInfo[4]
local aReg		:= aInfo[6]
local lRet		:= (len(aDadCon)>0)
local cChaveReg 	:= ''
local cChaveDad 	:= ''

if lRet
	cChaveReg := PLSRETDAD(aReg,"OPEMOV",'')+PLSRETDAD(aReg,"USUARIO",'')+PLSRETDAD(aReg,"CODRDA",'')+dtos(PLSRETDAD(aReg,"DATPRO",ctod('')))+PLSRETDAD(aReg,"GUIORI",'')    
	cChaveDad := PLSRETDAD(aDadCon[1,2],"OPEMOV",'')+PLSRETDAD(aDadCon[1,2],"USUARIO",'')+PLSRETDAD(aDadCon[1,2],"CODRDA",'')+dtos(PLSRETDAD(aDadCon[1,2],"DATPRO",ctod('')))+PLSRETDAD(aDadCon[1,2],"GUIORI",'')

	lRet := cChaveReg <> cChaveDad 
endIf

return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} IMPCCLI
Funcao Importar arquivos de Corpo clínico
@author Oscar Zanin
@since 04/05/2015
@version P12
/*/
//-------------------------------------------------------------------
user function IMPCCLI()

//Variáveis da rotina
Local nI			:= 1
Local cLogErro	:= "----------Log de Erros de Processamento----------" + CRLF + "----------Upload de Corpo Clínico----------" + CRLF + CRLF
Local cMask		:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local lErro		:= .F.
Local lTudoOk		:= .T.
Local lBau			:= .F.
Local lBb0			:= .F.
Local lBap			:= .F.
Local lBax			:= .F.
Local lBb8			:= .F.
Local lBf8			:= .F.
Local lBa8			:= .F.
Local lPreOk		:= .F.
Local aBC1			:= {}
Local aBE6			:= {}
Local aDadCon		:= paramixb[1] //Registro do Arquivo
/*
aDadCon - Layout: aDadCon[X][Y][Z][V]
[X] -> 'Número do Registro' Ímpar = CAB, Par = ITE. Dois 'registros' compõem uma linha do arquivo texto.
[X][1] => Descrição se CAB, ou ITE
[X][2] => Matriz com os dados
[X][2][Z] => Vetor com os dados de cada campo especificado (Ordem definida no Layout do arquivo texto)
[X][2][Z][1] => Nome do campo, sem o Alias da tabela
[X][2][Z][2] => Conteúdo do arquivo
*/

//Variáveis da BC1
Local cCodRDA		:= "" //Essa RDA é o médico que será adicionado ao corpo clínico da RDA principal
Local cCodPRF		:= ""
Local nPerSoc		:= 0
Local nPerDes		:= 0
Local nPerAcr		:= 0
Local cCodBlo		:= ""
Local cConsDv		:= ""
Local cObserv		:= ""
Local cCodigo		:= "" //Essa é a RDA principal
Local cCodEsp		:= ""
Local cCodLoc		:= ""
Local cCodInt		:= PLSINTPAD()

//Variáveis da BE6
Local cCodTab		:= ""
Local cCodPro		:= ""
Local cPgtDiv		:= ""
Local ctipTab		:= ""
Local cCodBB0		:= ""

//Importante: Temos esses selects de áreas pra não utilizar o ExistCpo na validações. O ExistCpo, caso dê 
//erro, abre uma janela para confirmação e isso ia forçar a pessoa a ficar dando OK pro processamento do 
//arquivo ir em frente.. se precisar adicionar novas validações aqui, não utilize o ExistCpo
If (select("BAU") == 0) //Verificamos se a BAU está aberta e, caso não, abrimos ela.
	BAU->(DbSelectArea("BAU"))
	lBau := .T.
EndIF
BAU->(DbSetOrder(1))

If (select("BB0") == 0) //Verificamos se a BB0 está aberta e, caso não, abrimos ela.
	BB0->(DbSelectArea("BB0"))
	lBb0 := .T.
EndIF
BB0->(DbSetOrder(1))

If (select("BAP") == 0) //Verificamos se a BAP está aberta e, caso não, abrimos ela.
	BAP->(DbSelectArea("BAP"))
	lBap := .T.
EndIf
BAP->(DbSetOrder(1))

If (select("BAX") == 0) //Verificamos se a BAX está aberta e, caso não, abrimos ela.
	BAX->(DbSelectArea("BAX"))
	lBax := .T.
EndIf
BAX->(DbSetOrder(1))

If (select("BB8") == 0) //Verificamos se a BB8 está aberta e, caso não, abrimos ela.
	BB8->(DbSelectArea("BB8"))
	lBb8 := .T.
EndIf
BB8->(DbSetOrder(1))

If (select("BF8") == 0) //Verificamos se a BF8 está aberta e, caso não, abrimos ela.
	BF8->(DbSelectArea("BF8"))
	lBf8 := .T.
EndIF
BF8->(DbSetOrder(3))

If (select("BA8") == 0) //Verificamos se a BA8 está aberta e, caso não, abrimos ela.
	BA8->(DbSelectArea("BA8"))
	lBa8	:= .T.
EndIf
BA8->(DbSetOrder(3))

While (nI < (Len(aDadCon))) 

	lErro := .F.

	If aDadCon[nI][1] == "CAB" //Número ímpar -> Verifica se é CAB
	
		//Buscamos valores dessa parte do registro (ver layout do aDadCon emc aso de dúvida, embaixo da declaração da variável)
		cCodRDA := aDadCon[nI][2][1][2]
		cCodPRF := aDadCon[nI][2][2][2]
		nPerSoc := Val(aDadCon[nI][2][3][2])
		nPerDes := Val(aDadCon[nI][2][4][2])
		nPerAcr := Val(aDadCon[nI][2][5][2])
		cCodBlo := aDadCon[nI][2][6][2]
		cConsDv := aDadCon[nI][2][7][2]
		cObserv := aDadCon[nI][2][8][2]
		cCodigo := aDadCon[nI][2][9][2]
		cCodEsp := aDadCon[nI][2][10][2]
		cCodLoc := aDadCon[nI][2][11][2]
		
		//Validações
		If !(BAU->(MsSeek(xFilial("BAU")+cCodRDA))) .AND. Vazio(cCodPRF)
			cLogErro += "RDA do corpo clínico não cadastrada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(Vazio(cCodRDA)) .AND. !(Vazio(cCodPRF))
			cLogErro += "Deve ser informado somente o código da RDA, ou do Profissional. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BB0->(MsSeek(xFilial("BB0")+cCodPRF))) .AND. Vazio(cCodRDA)
			cLogErro += "Profissional não cadastrado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF
		
		If (Vazio(cCodRDA) .AND. Vazio(cCodPRF))
			cLogErro += "Não foi informada RDA ou Profissional. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (Valtype(nPerSoc) <> "N") .AND. !(Vazio(nPerSoc))
			cLogErro += "Se Informado, o Percentual de Participação como sócio deve ser um valor numérico. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (ValType(nPerDes) <> "N") .AND. !(Vazio(nPerDes))
			cLogErro += "Se Informado, o Percentual de Desconto deve ser um valor numérico. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (Valtype(nPerAcr) <> "N") .AND. !(Vazio(nPerAcr))
			cLogErro += "Se Informado, o Percentual de Acréscimo deve ser um valor numérico. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BAP->(MsSeek(xFilial("BAP")+cCodBlo)))
			cLogErro += "Código de Bloqueio não cadastrado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF
		
		If cConsDv <> '0' .AND. cConsDv <> '1' .AND. !Vazio(cConsDv)
			cLogErro += "A Divisão de Remuneração deve ser 0 (Sim), 1 (Não), ou não preenchido. Preenchimento divergente. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (Len(AllTrim(cObserv)) > 100) //Isso gera um alerta só, não tem motivo do cliente reprocessar um arquivo por isso
			cLogErro += "O tamanho do campo de observação é 100 caracteres, o escedente disso foi desprezado na importação. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
		EndIf
		
		If Vazio(cCodigo)
			cLogErro += "Não foi informada RDA principal. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BAU->(MsSeek(xFilial("BAU")+cCodigo)))
			cLogErro += "RDA principal não cadastrada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If Vazio(cCodEsp)
			cLogErro += "Código da Especialidade da RDA principal não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BAX->(MsSeek(xFilial("BAX")+cCodigo+cCodInt+cCodLoc+cCodEsp)))
			cLogErro += "Código de Especialidade não cadastrado para a RDA principal. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If Vazio(cCodLoc)
			cLogErro += "Código do Local de Atendimento não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BB8->(MsSeek(xFilial("BB8")+cCodigo+cCodInt+cCodLoc)))
			cLogErro += "Código do Local de Atendimento não cadastrado para a RDA principal. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If (BAU->(MsSeek(xFilial("BAU")+cCodRDA)))
			If !(Vazio(BAU->(BAU_CODBB0)))
				cCodBB0 := BAU->(BAU_CODBB0)
				lPreOk := .T.
			EndIf
		EndIF
		
		If !(Vazio(cCodPRF))
			If (BB0->(MsSeek(xFilial("BB0")+cCodPRF)))
				cCodBB0 := cCodPRF
				lPreOk := .T.
			EndIF
		EndIF
		
		If !lPreOk
			cLogErro += "Não há código de profissional associado ao código de RDA Informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
			cCodBB0 := ""
		else
			cCodPRF := cCodBB0
		EndIF
						
		If !lErro	
			Aadd(aBC1, {cCodRDA, cCodPRF, nPerSoc, nPerDes, nPerAcr, cCodBlo, cConsDv, cObserv, xFilial("BC1"), cCodInt, cCodigo, cCodEsp, cCodLoc})
		EndIf
		
		nI := nI + 1 //Mudamos pra segunda parte do arquivo. Os incrementos do While ficam dentro do If caso ocorram de um registro ter só o CAB, ou o ITE.
	EndIf

	If aDadCon[nI][1] == "ITE" //Número Par -> Verifica se é ITE
		
		//Buscamos valores dessa parte do registro (ver layout do aDadCon em caso de dúvida, embaixo da declaração da variável)
		cCodTab	:= aDadCon[nI][2][1][2]
		cCodPro	:= aDadCon[nI][2][2][2]
		cPgtDiv 	:= aDadCon[nI][2][3][2]
		
		//Validações
		If Vazio(cCodTab)
			cLogErro += "Código da tabela padrão não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If !(BF8->(MsSeek(xFilial("BF8")+cCodTab)))
			cLogErro += "Código da tabela informada não cadastrado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		Else
			cTipTab := BF8->BF8_CODPAD		
		EndIf
		
		If !(BA8->(MsSeek(xFilial("BA8")+cTipTab+cCodPro)))
			cLogErro += "Código do procedimento inválido. Informado: " + cCodPro + ". Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (cPgtDiv <> '0' .AND. cPgtDiv <> '1' .AND. !(Vazio(cPgtDiv)))
			cLogErro += "Pagamento Dividido, se informado, deve ser 0 (Não) ou 1 (Sim). Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !lErro
			Aadd(aBE6, {cCodTab, cCodPro, cPgtDiv, xFilial("BE6"), cCodBB0, cCodLoc, cCodInt, cCodEsp, cCodigo, cTipTab})
		EndIf
				
		nI := nI + 1 //+1 pra seguir o While. Há o incremento total de +2 em nI a cada repetição, devido a linha do arquivo corresponder a 2 registros.	
	EndIf

If lErro
	cLogErro += CRLF
EndIf		

If lErro
	lTudoOk := .F.
EndIf

//Reinicia variáveis para o próximo ciclo
cCodBB0 := ""
lPreOk := .F.

EndDo

If lBau //Se abrimos a BAU, fechamos ela
	BAU->(DbCloseArea())
EndIf

If lBb0 //Se abrimos a BB0, fechamos ela
	BB0->(DbCloseArea())
EndIf

If lBap //Se abrimos a BAP, fechamos ela
	BAP->(DbCloseArea())
EndIf

If lBax //Se abrimos a BAX, fechamos ela
	BAX->(DbCloseArea())
EndIf

If lBb8 //Se abrimos a BB8, fechamos ela
	BB8->(DbCloseArea())
EndIf

If lBf8 //Se abrimos a BF8, fechamos ela
	BF8->(DbCloseArea())
EndIf

If lBa8 //Se abrimos a BA8, fechamos ela
	BA8->(DbCloseArea())
EndIF

If Len(aBC1) > 0 .AND. lTudoOk
	PLS365BC1(aBC1) //Gravação BC1, caso esteja tudo certo
EndIf

If Len(aBE6) > 0 .AND. lTudoOk
	PLS365BE6(aBE6) //Gravação BE6, caso esteja tudo certo
EndIf

aBC1 := {}
aBE6 := {}

//Dá mensagem de informação para o usuário
If !lTudoOk
	MsgStop("Há erros no arquivo, não foi possível a importação do mesmo. Verifique o Log para informações sobre os erros encontrados.", "Gravação não realizada")
else
	MsgInfo("Arquivo importado com sucesso!", "Gravação realizada")
EndIf

If !lTudoOk
	If MsgYesNo("Deseja salvar um arquivo com o Log da gravação? Se Sim, será necessário selecionar o arquivo [.TXT] que receberá o Log", "Gravar Log")
		cFile := cGetFile( cMask, "" )
		MemoWrite( cFile, cLogErro )
	EndIF
EndIf

Return(cLogErro)


//-------------------------------------------------------------------
/*/{Protheus.doc} IMPPROC
Funcao Importar arquivos de Corpo clínico
@author Oscar Zanin
@since 11/05/2015
@version P12
/*/
//-------------------------------------------------------------------
user function IMPPROC()

//Variáveis da rotina
Local nI			:= 1
Local cLogErro	:= "----------Log de Erros de Processamento----------" + CRLF + "----------Upload de Procedimentos Autorizados----------" + CRLF + CRLF
Local cMask		:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local lErro		:= .F.
Local lTudoOk		:= .T.
Local lBau			:= .F.
Local lBb0			:= .F.
Local lBap			:= .F.
Local lBax			:= .F.
Local lBb8			:= .F.
Local lBf8			:= .F.
Local lBa8			:= .F.
Local aBC0			:= {}
Local aDadCon		:= paramixb[1] //Registro do Arquivo
/*
aDadCon - Layout: aDadCon[X][Y][Z][V]
[X] -> 'Número do Registro' Ímpar = CAB, Par = ITE. Dois 'registros' compõem uma linha do arquivo texto.
[X][1] => Descrição se CAB, ou ITE
[X][2] => Matriz com os dados
[X][2][Z] => Vetor com os dados de cada campo especificado (Ordem definida no Layout do arquivo texto)
[X][2][Z][1] => Nome do campo, sem o Alias da tabela
[X][2][Z][2] => Conteúdo do arquivo
*/
//Variáveis que vão ir pro vetor de gravação
Local cFili	:= ""
Local cCodigo	:= ""
Local cCodInt	:= ""
Local cCodLoc := ""
Local cCodEsp	:= ""
Local cCodTab	:= ""
Local cCodOpc	:= ""
Local nValCh	:= 0
Local nValRea	:= 0
Local cFormul	:= ""
Local cExpress:= ""
Local nPerDes	:= 0
Local nPerAcr	:= 0
Local cTipo	:= ""
Local dVigDe
Local dVigAte
Local nBanda	:= 0
Local nUCO		:= 0
Local cCodBlo	:= ""
Local dDatblo
Local cObserv	:= ""
Local cTipTAb := ""

//Importante: Temos esses selects de áreas pra não utilizar o ExistCpo na validações. O ExistCpo, caso dê 
//erro, abre uma janela para confirmação e isso ia forçar a pessoa a ficar dando OK pro processamento do 
//arquivo ir em frente.. se precisar adicionar novas validações aqui, não utilize o ExistCpo
If (select("BAU") == 0) //Verificamos se a BAU está aberta e, caso não, abrimos ela.
	BAU->(DbSelectArea("BAU"))
	lBau := .T.
EndIF
BAU->(DbSetOrder(1))

If (select("BB0") == 0) //Verificamos se a BB0 está aberta e, caso não, abrimos ela.
	BB0->(DbSelectArea("BB0"))
	lBb0 := .T.
EndIF
BB0->(DbSetOrder(1))

If (select("BAP") == 0) //Verificamos se a BAP está aberta e, caso não, abrimos ela.
	BAP->(DbSelectArea("BAP"))
	lBap := .T.
EndIf
BAP->(DbSetOrder(1))

If (select("BAX") == 0) //Verificamos se a BAX está aberta e, caso não, abrimos ela.
	BAX->(DbSelectArea("BAX"))
	lBax := .T.
EndIf
BAX->(DbSetOrder(1))

If (select("BB8") == 0) //Verificamos se a BB8 está aberta e, caso não, abrimos ela.
	BB8->(DbSelectArea("BB8"))
	lBb8 := .T.
EndIf
BB8->(DbSetOrder(1))

If (select("BF8") == 0) //Verificamos se a BF8 está aberta e, caso não, abrimos ela.
	BF8->(DbSelectArea("BF8"))
	lBf8 := .T.
EndIF
BF8->(DbSetOrder(3))

If (select("BA8") == 0) //Verificamos se a BA8 está aberta e, caso não, abrimos ela.
	BA8->(DbSelectArea("BA8"))
	lBa8	:= .T.
EndIf
BA8->(DbSetOrder(3))

While (nI < (Len(aDadCon))) 

	lErro := .F.

	If aDadCon[nI][1] == "CAB" //Número ímpar -> Verifica se é CAB
	
		//Buscamos valores dessa parte do registro (ver layout do aDadCon emc aso de dúvida, embaixo da declaração da variável)
		cFili := xFilial("BC0")
		cCodigo := aDadCon[nI][2][1][2]
		cCodInt := aDadCon[nI][2][2][2]
		cCodLoc := aDadCon[nI][2][3][2]
		cCodEsp := aDadCon[nI][2][4][2]
		
		//Validações
		If Vazio(cCodigo)
			cLogErro += "RDA não informada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If Vazio(cCodInt)
			cLogErro += "Operadora não informada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If Vazio(cCodLoc)
			cLogErro += "Local de Atendimento não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If Vazio(cCodEsp)
			cLogErro += "Especialidade não informada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
								
		If !(BAU->(MsSeek(xFilial("BAU")+cCodigo)))
			cLogErro += "RDA Informada não cadastrada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (cCodInt <> PLSINTPAD())
			cLogErro += "Operadora informada inválida. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF
		
		If !(BB8->(MsSeek(cFili+cCodigo+cCodInt+cCodLoc)))
			cLogErro += "Local de Atendimento informado inválido. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF
		
		If !(BAX->(MsSeek(cFili + cCodigo + cCodInt + cCodLoc + cCodEsp)))
			cLogErro += "Especialidade informada inválida. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF
		
		nI := nI + 1 //Mudamos pra segunda parte do arquivo. Os incrementos do While ficam dentro do If caso ocorram de um registro ter só o CAB, ou o ITE.
	EndIf
		
	If aDadCon[nI][1] == "ITE" //Número Par -> Verifica se é ITE
		
		//Buscamos valores dessa parte do registro (ver layout do aDadCon em caso de dúvida, embaixo da declaração da variável)
		cCodTab	:= aDadCon[nI][2][1][2]
		cCodOpc	:= aDadCon[nI][2][2][2]
		nValCh 	:= aDadCon[nI][2][3][2]
		nValRea	:= aDadCon[nI][2][4][2]
		cFormul	:= aDadCon[nI][2][5][2]
		cExpress	:= aDadCon[nI][2][16][2]
		nPerDes	:= aDadCon[nI][2][6][2]
		nPerAcr	:= aDadCon[nI][2][7][2]
		cTipo		:= aDadCon[nI][2][8][2]
		dVigDe		:= aDadCon[nI][2][9][2]
		dVigAte	:= aDadCon[nI][2][10][2]
		nBanda		:= aDadCon[nI][2][11][2]
		nUCO		:= aDadCon[nI][2][12][2]
		cCodBlo	:= aDadCon[nI][2][13][2]
		dDatBlo	:= aDadCon[nI][2][14][2]
		cObserv	:= aDadCon[nI][2][15][2]
	
		//Validações
		If Vazio(cCodTab)
			cLogErro += "Código da tabela padrão não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If Vazio(cCodOpc)
			cLogErro += "Procedimento não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !(BF8->(MsSeek(xFilial("BF8")+cCodTab)))
			cLogErro += "Código da tabela informada não cadastrado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		Else
			cTipTab := BF8->BF8_CODPAD		
		EndIf
		
		If !(BA8->(MsSeek(xFilial("BA8")+cTipTab+cCodOpc)))
			cLogErro += "Código do procedimento inválido. Informado: " + cCodOpc + ". Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (nValCh > 0 .AND. nValRea > 0)
			cLogErro += "Deve ser informado somente Valor em U.S. ou valor Fixo. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (ValType(nValCh) <> "N") .AND. !(Vazio(nValCh))
			cLogErro += "O valor de U.S. deve ser numérico, ou não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (ValType(nValRea) <> "N") .AND. !(Vazio(nValRea))
			cLogErro += "O valor Fixo deve ser numérico, ou não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (ValType(nPerDes) <> "N") .AND. !(Vazio(nPerDes))
			cLogErro += "Se Informado, o Percentual de Desconto deve ser um valor numérico. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If (Valtype(nPerAcr) <> "N") .AND. !(Vazio(nPerAcr))
			cLogErro += "Se Informado, o Percentual de Acréscimo deve ser um valor numérico. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If (ValType(nUCO) <> "N") .AND. !(Vazio(nUCO))
			cLogErro += "O valor de UCO deve ser numérico, ou não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf

		If (ValType(nBanda) <> "N") .AND. !(Vazio(nBanda))
			cLogErro += "O valor da Banda deve ser numérico, ou não informado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
						
		If !(BAP->(MsSeek(xFilial("BAP")+cCodBlo)))
			cLogErro += "Código de Bloqueio não cadastrado. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIF

		If (Len(AllTrim(cObserv)) > 100) //Isso gera um alerta só, não tem motivo do cliente reprocessar um arquivo por isso
			cLogErro += "O tamanho do campo de observação é 100 caracteres, o escedente disso foi desprezado na importação. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
		EndIf
	
		If (cFormul <> '1' .AND. cFormul <> '2' .AND. !(Vazio(cFormul)))
			cLogErro += "O campo Fórmula deve ser 1 (Fixa), 2 (Expressão), ou não informado. Preenchimento divergente. Preenchimento: " + cFormul + ". Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf		
		
		If cFormul == '2' .AND. Vazio(cExpress)
			cLogErro += "Se indicada fórmula = Expressão, a expressão deve ser informada. Linha : " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If cFormul <> '2' .AND. !(Vazio(cExpress))
			cLogErro += "Se indicada fórmula diferente de 'Expressão', a expressão não deve ser informada. Linha: " + AllTrim(Str(Ceiling(nI/2))) + CRLF
			lErro := .T.
		EndIf
		
		If !lErro	
			Aadd(aBC0, {cFili, cCodigo, cCodInt, cCodLoc, cCodEsp, cCodTab, cCodOpc, nValCh, nValRea, cFormul, cExpress, nPerDes, nPerAcr, cTipo, dVigDe, dVigAte, nBanda, nUCO, cCodBlo, dDatblo, cObserv, cTipTab})
		EndIf
		
		nI := nI + 1 //Mudamos pra segunda parte do arquivo. Os incrementos do While ficam dentro do If caso ocorram de um registro ter só o CAB, ou o ITE.
	EndIf		

	If lErro
		cLogErro += CRLF
	EndIf		

	If lErro
		lTudoOk := .F.
	EndIf

EndDo

If lBau //Se abrimos a BAU, fechamos ela
	BAU->(DbCloseArea())
EndIf

If lBb0 //Se abrimos a BB0, fechamos ela
	BB0->(DbCloseArea())
EndIf

If lBap //Se abrimos a BAP, fechamos ela
	BAP->(DbCloseArea())
EndIf

If lBax //Se abrimos a BAX, fechamos ela
	BAX->(DbCloseArea())
EndIf

If lBb8 //Se abrimos a BB8, fechamos ela
	BB8->(DbCloseArea())
EndIf

If lBf8 //Se abrimos a BF8, fechamos ela
	BF8->(DbCloseArea())
EndIf

If lBa8 //Se abrimos a BA8, fechamos ela
	BA8->(DbCloseArea())
EndIF

If Len(aBC0) > 0 .AND. lTudoOk
	PLS365BC0(aBC0) //Gravação BC0, caso esteja tudo certo
EndIf

aBC0 := {}

//Dá mensagem de informação para o usuário
If !lTudoOk
	MsgStop("Há erros no arquivo, não foi possível a importação do mesmo. Verifique o Log para informações sobre os erros encontrados.", "Gravação não realizada")
else
	MsgInfo("Arquivo importado com sucesso!", "Gravação realizada")
EndIf

If !lTudoOk
	If MsgYesNo("Deseja salvar um arquivo com o Log da gravação? Se Sim, será necessário selecionar o arquivo [.TXT] que receberá o Log", "Gravar Log")
		cFile := cGetFile( cMask, "" )
		MemoWrite( cFile, cLogErro )
	EndIF
EndIf

Return (cLogErro)
