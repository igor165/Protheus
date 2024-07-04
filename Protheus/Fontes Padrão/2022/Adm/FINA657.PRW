#INCLUDE "FINA657.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FINA657
Fun็ใo do Processamento: Disponibilizar rotinas para exportacao de participantes
para o Sistema Reserve.
Desenvolvido conforme manual de integra็ใo do Reserve
Esta fun็ใo Processa a Tabela de Pessoas (RD0) enviando vias webservice os dados das pessoas
ainda nใo exportadas

@param aParam Parametro passado pelo schedule do Protheus para inicializar o ambiente se nใo passada sera
usado o ambiente do qual o rotina foi chamada.

@return Nada
@author Alexandre Circenis
@since 04/09/2013
@version MP1190
/*/
function FINA657(aParam)
Local nCont		:= 0
Local oUsers	:= WSUsuarios():New()
Local oSvc
Local cSessao
Local lEnd
Local cAliasTrb	:= GetNextAlias()
Local lAlone	:= aParam <> NIL
Local lDel		:= .F. //Ha registros deletados a processar
Local lExpRD0	:= SubStr(SuperGetMV("MV_RESCAD",.F.,"111"),3,1) == "1"	//Verifica se a exportacao do participante esta habilitada
Default aParam	:= {"","","",""}

If lExpRD0
	//Quando nใo se recebe os parametros rotina foi chamada por um JOB
	//e nใo precisa setar o ambiente. usamos o ambiente jแ criado pelo JOB
	if lAlone
		RpcSetType(3)
		RPCSetEnv(aParam[1],aParam[2],,,"FIN")
	endif

	if FINXRESOSe(@cSessao, @oSvc, "RD0")

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Seleciona os Participantes a serem exportados     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		BeginSql Alias cAliasTrb
			SELECT R_E_C_N_O_ RECNORD0
			FROM %table:RD0%
			WHERE RD0_FILATU = %exp:cFilAnt%
			AND RD0_EMPATU = %exp:cEmpAnt%
			AND RD0_RESERV <> '1'
			AND ((RD0_DVIAGE <> '1'
			AND RD0_DVIAGE <> ' ')
			OR RD0_MSBLQL <> '2')
			AND RD0_LOGINR <> ' '
		EndSql
	
		lEnd := (cAliasTrb)->(Eof())
	
		if !lEnd // Ha Registros a processar
		
			oUsers:oWSAtualizarRQ:CSESSAO := cSessao
			oUsers:oWSAtualizarRQ:oWSCadastros := Usuarios_ArrayOfDados():New()
		
			dbSelectArea("RD0")
		
			While !lEnd
				RD0->(dbGoto((cAliasTrb)->RECNORD0))
				lDel := RD0->(Deleted())
				// Busca os dados do usuario da RD0 para atulizar o reserve
				Aadd(oUsers:oWSAtualizarRQ:oWSCadastros:oWSDados, FINA657USE(cEmpAnt, cFilAnt, RD0->RD0_RESERV = '6'))
				nCont++
				(cAliasTrb)->(dbSkip())
				lEnd := (cAliasTrb)->(Eof())
				if nCont >= 100 .or. lEnd // Mandaremos no maximo 100 usarios de cada vez.
					oUsers:Atualizar()
					FINA657PRO(oUsers:OWSATUALIZARRESULT, lDel) // Processa o resultado do manuten็ใo dos usuarios no Reserve
					nCont := 0
					FN657Conf(oUsers, cSessao)
					oUsers:oWSAtualizarRQ := Usuarios_ATUALIZARUSUARIOSRQ():New()
					oUsers:oWSAtualizarRQ:CSESSAO := cSessao
					oUsers:oWSAtualizarRQ:oWSCadastros := Usuarios_ArrayOfDados():New()
				endif

			enddo

			dbSelectArea("RD0")

		endif

		FINXRESCSe(cSessao,oSvc)

		(cAliasTrb)->(DbCloseArea())

	endif

EndIf

if lAlone
	RPCClearEnv()
endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657USEบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche os dodos do usuario com base no registro da RD0   บฑฑ
ฑฑบ          ณ posicionado                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FINA657USE(cEmp, cFil, lTransf)
Local lAtivo	:= RD0->RD0_MSBLQL <> "1"  .And. !RD0->(Deleted()) // Bloqueado ou deletado
Local oUser
Local cTelefone	:= ""
Local cCelular	:= ""
Local nX
Local lNew		:= Val(RD0->RD0_IDRESE) = 0 // ID Reserve nao preenchido e novo 
Local lExist	:= .T.
Local cBK0Age	:=  Alltrim(BKO2AGE(RD0->RD0_EMPATU+RD0->RD0_FILATU, @lExist))
Local cTipIdent	:= if(lNew,'1','0') // Quando novo identificar pela matricula e pelo id reserve nos demais casos
Local lFA657AUT	:= ExistBlock("FA657AUT")
Local cAutPref	:= "" 
Local cCCusto	:= ""
Local aRetAut	:= {}
Local cGrupAces	:= SuperGetMv("MV_RESGRAC",.F.,"E.12")

Default lTransf := .F.

if lFA657AUT  

	aRetAut := ExecBlock("FA657AUT",.F.,.F.,{RD0->RD0_CODIGO})
	if aRetAut = NIL .or. ValType(aRetAut) <>  "A"
		cCCusto  := ""
		cAutPref := ""
	elseif len(aRetAut) <> 2
		cCCusto  := ""
		cAutPref := ""
	elseif Valtype(aRetAut[1]) <> "C" .or. Valtype(aRetAut[2]) <> "C"
		cCCusto  := ""
		cAutPref := ""
	else
		cAutPref := aRetAut[1] 
		cCCusto  := aRetAut[2]
	endif

endif

if lTransf .and. !lExist // eh uma transferencia e o codigo da empras destino nใo existe.
	// Devemos apenas inativar o usuario e nใo trasferi-lo
	// pois a empresa destino nใo existe no Reserve
	lAtivo := .F.
	cBK0Age :=  Alltrim(BKO2AGE(RD0->RD0_EMPANT+RD0->RD0_FILANT))
	lTransf := .F.
endif

for nX := 1 to Len(RD0->RD0_FONE)                     

	cTelefone += if(Substr(RD0->RD0_FONE,nX,1) $"0123456789", Substr(RD0->RD0_FONE,nX,1), "")

next

oUser := Usuarios_Dados():NEW()

oUser:cNome					:= AllTrim(RD0->RD0_NOME)
oUser:cEmail				:= Lower(AllTrim(RD0->RD0_EMAIL))
oUser:cMatricula			:= AllTrim(RD0->RD0_CODIGO)

oUser:oWSTelefone			:= Usuarios_Telefone():New()
oUser:oWSTelefone:cCodArea	:= AllTrim(RD0->RD0_DDD)
oUser:oWSTelefone:cCodPais	:= If(Empty(AllTrim(RD0->RD0_DDI)), "55",AllTrim(RD0->RD0_DDI))
oUser:oWSTelefone:cTelefone	:= cTelefone

oUser:oWSSexo				:= Usuarios_Sexo():New()
oUser:oWSSexo:VALUE			:= If(RD0->RD0_SEXO = "M","0","1") // 0 - Masculino; 1- Feminino

oUser:oWSIdioma				:= Usuarios_Idioma():New()
oUser:oWSIdioma:VALUE		:= "0"  // usamos por enquanto a idioma padrao do brasil Portugues

oUser:cCodEmpresa			:= cBK0Age // Codigo da Empresa que se esta posicionado no Reserve

//------------------
// Dados do Usuario
//------------------
oUser:oWSUsuario 							:= Usuarios_DadosAcesso():New()
oUser:oWSUsuario:cLogin 					:=  Alltrim(RD0->RD0_LOGINR) // Login do Reserve
oUser:oWSUsuario:nIdReserve 				:= Val(Alltrim(RD0->RD0_IDRESE))
oUser:oWSUsuario:cIDGrupoAcesso 			:= Alltrim(cGrupAces) 
oUser:oWSUsuario:oWSNivelAutorizacao 		:= Usuarios_NivelAutorizacao():New()
oUser:oWSUsuario:oWSNivelAutorizacao:VALUE 	:= '0'
oUser:oWSUsuario:oWSServicoArea      		:= Usuarios_ServicoArea():New()
oUser:oWSUsuario:oWSServicoArea:Value 		:= '0'
oUser:oWSUsuario:oWSServicoTipo      		:= Usuarios_ServicoTipo():New()
oUser:oWSUsuario:oWSServicoTipo:Value 		:= '0'
oUser:oWSUsuario:lPedePaxVIP               	:= .F.
oUser:oWSUsuario:lAtivo                    	:=  lAtivo
oUser:oWSUsuario:oWSTipoIdentificador := Usuarios_TipoIdentificador():New()
oUser:oWSUsuario:oWSTipoIdentificador:Value := cTipIdent  
if lTransf
	oUser:oWSUsuario:cCodEmpresaOriginal	:= Alltrim(BKO2AGE(RD0->RD0_EMPANT+RD0->RD0_FILANT)) // Codigo da Empresa que se esta posicionado no Reserve
endif
//---------------------
// Dados do Passageiro
//---------------------

for nX := 1 to Len(RD0->RD0_NUMCEL)                     

	cCelular += if(Substr(RD0->RD0_NUMCEL,nX,1) $"0123456789", Substr(RD0->RD0_NUMCEL,nX,1), "")

next

oUser:oWSPassageiro := Usuarios_DadosPax():New()
oUser:oWSPassageiro:nIDReserve 	:= Val(Alltrim(RD0->RD0_IDRESE))
oUser:oWSPassageiro:oWSCelular			:= Usuarios_Telefone():New()
oUser:oWSPassageiro:oWSCelular:cCodPais	:= If(Empty(AllTrim(RD0->RD0_DDI)), "55",AllTrim(RD0->RD0_DDI))
oUser:oWSPassageiro:oWSCelular:cCodArea	:= AllTrim(RD0->RD0_DDD)
oUser:oWSPassageiro:oWSCelular:cTelefone  := cCelular

oUser:oWSPassageiro:cCpf := Alltrim(RD0->RD0_CIC) 


//**************************************************************************************//
// Posicionado na RD0 faz a busca no SRA e envia as informa็๕es abaixo para o reserve   //
//**************************************************************************************//

DbSelectArea("SRA")
DbSetOrder(5)
If dbSeek(xFilial("SRA")+RD0->RD0_CIC)
	oUser:oWSPassageiro:cRG  := AllTrim(SRA->RA_RG) + Iif(cPaisLoc=="BRA",AllTrim(SRA->RA_COMPLRG),"")
	oUser:oWSPassageiro:cNumeroHabilitacao := AllTrim(SRA->RA_HABILIT)
EndIf

dbSelectArea("RD0")

if Empty(cCCusto)
	oUser:oWSPassageiro:cCentroCusto := Alltrim(RD0->RD0_CC)
else
	oUser:oWSPassageiro:cCentroCusto := Alltrim(cCCusto)
endif	
oUser:oWSPassageiro:cDataNascimento  := Transform(dtos(RD0->RD0_DTNASC),"@r 9999-99-99")
oUser:oWSPassageiro:lIsentoPoliticas := .F.
oUser:oWSPassageiro:lAtivo           := lAtivo
oUser:oWSPassageiro:cNivelCargo      := Alltrim(RD0->RD0_NVLCAR)

oUser:oWSPassageiro:oWSTipoIdentificador := Usuarios_TipoIdentificador():New()
oUser:oWSPassageiro:oWSTipoIdentificador:Value := cTipIdent

if !Empty(cAutPref)
	oUser:oWSPassageiro:cIDAutPreferencial := cAutPref
endif

Return oUser

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657PROบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o retorno do WEBSERVICE do Reserve logando o errosบฑฑ
ฑฑบ          ณ caso houverem                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FINA657PRO(oResultado,lDelete)

Local aUsuarios
Local aPaX
Local lUserFail := .F.
Local lPaxFail  := .F.
Local lHaErros  := .F.
Local nX := 0
Local nY := 0
Local cStatus := '1' // Sucesso na inclusao
Local aAreaRd0 := RD0->(GetArea())
Local lPartic := .T.
Local aErro :={}
Local lSetDeleted := SET(_SET_DELETED)

Default lDelete := .F. 

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiveis Status         ณ
//ณ0 - Nใo Enviado         ณ
//ณ1 - Incluido com Sucessoณ
//ณ2 - Nใo Incluido        ณ
//ณ3 - Usuario com Erro    ณ
//ณ4 - Passageiro com erro ณ
//ณ5- Ambos com Erro       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DOC*/

RD0->(dbSetOrder(1))

if aUsuarios := oResultado:OWSCADASTROS <> NIL

	aUsuarios := oResultado:OWSCADASTROS:OWSUSUARIOS
	aPaX      := oResultado:OWSCADASTROS:OWSPASSAGEIROS
	if Len(aUsuarios:oWSCadastro) > 0
		// Processamento do Resultado da Manutencao solicitada ao reserve
		for nY := 1 TO Len(aUsuarios:oWSCadastro)
			lUserFail := .F.
			lHaErros := .F.
			lPaxFail := .F.

			cStatus := '1'

			if aUsuarios:oWSCadastro[nY]:nIDReserve = NIL // Falhou a inclusใo no reserve marcar RD0
				lUserFail := .T.
			Endif
			SET(_SET_DELETED, !lDelete)
			if !dbSeek(xFilial("RD0")+Alltrim(aUsuarios:oWSCadastro[nY]:cMatricula))
				Aadd(aErro,STR0001 + "0000") //"CCODERRO: "
				Aadd(aErro,STR0002+ STR0003+Alltrim(aUsuarios:oWSCadastro[nY]:cMatricula)+STR0004) //"CMENSAGEM: "###"Participante matricula "###" nao disponivel no sistema"
				lPartic := .F.
			endif

			// Nใo falhou a grava็ใo
			if aUsuarios:oWSCadastro[nY]:OWSERROS <> NIL
				if Len(aErro) = 0
					Aadd(aErro,STR0003+Alltrim(aUsuarios:oWSCadastro[nY]:cMatricula)) //"Participante matricula "
				endif
				Aadd(aErro,STR0002+ STR0005) //"CMENSAGEM: "###"Manutencao de Usuarios"
				for nx := 1 to Len(aUsuarios:oWSCadastro[nY]:OWSERROS:oWSErro)
					Aadd(aErro,STR0001 + aUsuarios:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
					Aadd(aErro,STR0002+ aUsuarios:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
				Next nX
				cStatus := If(cStatus="1","4","5")
			endif

			if lUserFail // Usuario nใo processado
				cStatus := '2'
			else // Verificar os dados do Passageiro
				cStatus := if(lHaErros, "3","1") // Se hแ erros o usuario foi incluido com dados errados
				nPax := aScan(aPax:oWSCadastro, {|x| x:cMatricula = aUsuarios:oWSCadastro[nY]:cMatricula})
				if nPax > 0 // Havia dados de passageiro para esse usuario.
					if aPax:oWSCadastro[nPax]:OWSERROS <> NIL
						if Len(aErro) = 0
							Aadd(aErro,STR0003+Alltrim(aUsuarios:oWSCadastro[nY]:cMatricula)) //"Participante matricula "
						endif
						Aadd(aErro,STR0002+ STR0006) //"CMENSAGEM: "###"Manutencao de Passageiro"
						For nX := 1 To Len(aPax:oWSCadastro[nPax]:OWSERROS:OWSERRO)
							Aadd(aErro,STR0001 + aPax:oWSCadastro[nPax]:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
							Aadd(aErro,STR0002+ aPax:oWSCadastro[nPax]:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
						Next nX
						cStatus := If(cStatus="1","4","5")
						lHaErros := .t.
					endif
				endif
			endif

			if Len(aErro) > 0
				FINXRESLog("RD0",STR0007,Str(RD0->(RECNO())),aErro) //"Exportacao de Participantes"
				aErro := {}
			endif
			
			dbSelectArea("RD0")
			if lPartic
				Reclock("RD0",.F.)
				RD0->RD0_RESERV := cStatus
				If !Empty(aUsuarios:oWSCadastro[nY]:nIDReserve)
					RD0->RD0_IDRESE := Str(aUsuarios:oWSCadastro[nY]:nIDReserve,9,0)
				endif
				MsUnlock()
			endif
			
		next nY
	else
		
		Aadd(aErro,STR0008) //"Erros no XML"
		Aadd(aErro,STR0009) //"Erros no XML de envio do(s) funcionarios para o Reserve"
		Aadd(aErro,STR0010) //"Verifique os campos do cadastro de Participantes"
		FINXRESLog("RD0",STR0007,"",aErro) //"Exportacao de Participantes"
		
	endif
else
	if oResultado:OWSERROS <> NIL
		Aadd(aErro,STR0008) //"Erros no XML"
		For nX := 1 To Len(oResultado:OWSERROS:OWSERRO)
			Aadd(aErro,"CCODERRO: " + oResultado:OWSERROS:OWSERRO[nX]:CCODERRO)
			Aadd(aErro,"CMENSAGEM: "+ oResultado:OWSERROS:OWSERRO[nX]:CMENSAGEM)
		Next nX
		FINXRESLog("RD0",STR0007,"",aErro) //"Exportacao de Participantes"
	else
		Aadd(aErro,STR0008) //"Erros no XML"
		Aadd(aErro,STR0009) //"Erros no XML de envio do(s) funcionarios para o Reserve"
		Aadd(aErro,STR0010) //"Verifique os campos do cadastro de Participantes"
		FINXRESLog("RD0",STR0007,"",aErro) //"Exportacao de Participantes"
	endif
	
endif

SET(_SET_DELETED,lSetDeleted)
RestArea(aAreaRd0)

Return Len(aErro)= 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657MntบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao executada a partir do cadastro de participantes para บฑฑ
ฑฑบ          ณintegracao com o Sistema Reserve                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA657Mnt(cEmp, cFil)
default cEmp := cEmpAnt
default cFil := cFilAnt

DatIntRes()
if !RD0->RD0_DVIAGE $ " 1" .and. !Empty(RD0->RD0_LOGINR) // Eh viajante e tem Login Cadastrado
	if RD0->(Deleted()) // RD0 deletado
		MsgRun(STR0011,STR0012,{|| FINA657Int(cEmp, cFil,,.T.)})	 //"Integrando com o Sistema Reserve"###"Integra็ใo Reserve"
	else
		MsgRun(STR0011,STR0012,{|| FINA657Int(cEmp, cFil,,.F.)}) //"Integrando com o Sistema Reserve"###"Integra็ใo Reserve"
	endif	
endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657IntบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo responsavel pela exporta็ใo de um unico participante บฑฑ
ฑฑบ          ณusada no cadastro de participantes para atualizar o Reserve บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA657Int(cEmp, cFil, lTransf, lDel)
Local oUsers	:= WSUsuarios():New()
Local oSvc		:= Nil
Local cSessao	:= ""

Default cEmp := ''
Default cFil := ''
Default lTransf := .F.
Default lDel := .F.

If FINXRESOSe(@cSessao,@oSvc,"RD0")

	oUsers:oWSAtualizarRQ:CSESSAO := cSessao
	oUsers:oWSAtualizarRQ:oWSCadastros := Usuarios_ArrayOfDados():New()

	dbSelectArea("RD0")
	Aadd(oUsers:oWSAtualizarRQ:oWSCadastros:oWSDados, FINA657USE(cEmp,cFil, lTransf))
	oUsers:Atualizar()
	FINA657PRO(oUsers:OWSATUALIZARRESULT, lDel) // Processa o resultado do manuten็ใo dos usuarios no Reserve
	FN657Conf(oUsers, cSessao)

	// Busca os dados do usuario da RD0 para atulizar o reserve

	FINXRESCSe(cSessao,oSvc)

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657ApgบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo responsavel pela Excluso de um unico participante    บฑฑ
ฑฑบ          ณusada no cadastro de participantes para atualizar o Reserve บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA657Apg(cEmp, cFil)
Local oUsers	:= WSUsuarios():New()
Local oSvc		:= Nil
Local cSessao	:= ""
Local aDel := {}
Local aPax  := {}

Default cEmp := ''
Default cFil := '' 

WSDLSetProfile(.t.)
WSDLDbgLevel(2)

If FINXRESOSe(@cSessao,@oSvc,"RD0")

	oUsers:OWSEXCLUIRRQ:CSESSAO := cSessao
	oUsers:OWSEXCLUIRRQ:OWSFILTROS := FN657INIDel()
	aAdd(aDel ,Alltrim(RD0->RD0_LOGINR))                                    
	aAdd(aPax, {Val(RD0->RD0_IDRESE),RD0->(Recno())})
	oUsers:OWSEXCLUIRRQ:OWSFILTROS:oWSLogins:cLogin := aDel
    oUsers:OWSEXCLUIRRQ:OWSFILTROS:oWSCODEmpresas:cCODEmpresa :={Alltrim(BKO2AGE())}
  	oUsers:Excluir()
	Fina657Tra(oUsers:oWSExcluirResult, aPax)
	
	FINXRESCSe(cSessao,oSvc)

endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657DELบAutor  ณAlexandre Circenis  บ Data ณ  09/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona os Participantes a serem Excluidos                บฑฑ
ฑฑบ          ณdevido a tranferencia                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Fina657TRF(cSessao)

Local oUsers := WSUsuarios():New()
Local cAliasTrb := GetNextAlias()
Local aDel := {}
Local aPax  := {}
Local aArea := GetArea()

oUsers:OWSEXCLUIRRQ:CSESSAO := cSessao
oUsers:OWSEXCLUIRRQ:OWSFILTROS := FN657INIDel()

BeginSql Alias cAliasTrb
	SELECT R_E_C_N_O_ RECNORD0
	FROM %table:RD0%
	WHERE RD0_FILATU = %exp:cFilAnt%
	AND RD0_EMPATU   = %exp:cEmpAnt%
	AND RD0_RESERV  = '6'
	AND RD0_IDRESE <> ' '
EndSql

aDel := {}
aPax := {}

while !(cAliasTrb)->(Eof())
	RD0->(dbGoto((cAliasTrb)->RECNORD0))
	aAdd(aDel ,RD0->RD0_LOGINR)
	aAdd(aPax, {Val(RD0->RD0_IDRESE),RD0->(Recno())})
	(cAliasTrb)->(dbSkip())	
enddo

if Len(aDel) > 0
	oUsers:OWSEXCLUIRRQ:OWSFILTROS:oWSLogins:cLogin := aDel
	oUsers:Excluir()
	Fina657Tra(oUsers:oWSExcluirResult, aPax)
endif

(cAliasTrb)->(DbCloseArea())

RestArea(aArea)

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657TraบAutor  ณAlexandre Circenis  บ Data ณ  09/19/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa o retorna da exclusao para verificar as possiveis บฑฑ
ฑฑบ          ณ falhas na exclusใo do participante                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Fina657Tra(oResultado, aPassageiro)

Local aUsuarios
Local lUserFail := .F.
Local lPaxFail  := .F.
Local lHaErros  := .F.
Local nX := 0
Local nY := 0
Local cStatus := '0' // Transferido pendende de inclusao na nova empresa
Local aAreaRd0 := RD0->(GetArea())
Local lPartic := .T.
Local aErro :={}
Local aPax

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiveis Status         ณ
//ณ0 - Nใo Enviado         ณ
//ณ1 - Incluido com Sucessoณ
//ณ2 - Nใo Incluido        ณ
//ณ3 - Usuario com Erro    ณ
//ณ4 - Passageiro com erro ณ
//ณ5 - Ambos com Erro      ณ
//ณ6 - Pendente de Transferณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DOC*/

RD0->(dbSetOrder(1))

if aUsuarios := oResultado:OWSCADASTROS <> NIL
	
	aPax      := oResultado:OWSCADASTROS:OWSPASSAGEIROS
	if aPax <> NIL .and. Len(aPax:oWSCadastro) > 0
		// Processamento do Resultado da Exclusao solicitada ao reserve
		for nY := 1 TO Len(aPax:oWSCadastro)
			lUserFail := .F.
			lHaErros := .F.
			lPaxFail := .F.

			cStatus := '1'
			nPax := aScan( aPassageiro ,{|x| x[1] = Str(aPax:oWSCadastro[nY]:nIDReserve,9,0)})
			if nPax > 0
				// Nใo falhou a grava็ใo
				if aPax:oWSCadastro[nY]:OWSERROS <> NIL
					if Len(aErro) = 0
						Aadd(aErro,STR0003+Alltrim(aPax:oWSCadastro[nY]:cMatricula)) //"Participante matricula "
					endif
					Aadd(aErro,STR0002+ STR0013) //"CMENSAGEM: "###"Exclusใo de Usuarios"
					for nx := 1 to Len(aPax:oWSCadastro[nY]:OWSERROS:oWSErro)
						Aadd(aErro,STR0001 + aPax:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
						Aadd(aErro,STR0002+ aPax:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
					Next nX
				endif
			endif

			if Len(aErro) > 0
				FINXRESLog("RD0",STR0014, Str(RD0->(RECNO())),aErro) //"Exclusao de Participantes"
				aErro := {}
				aPassageiro := aDel(aPassageiro,nPax)
				aSize(aPassageiro, Len(aPassageiro)-1)
			endif

		next nY
	endif
else
	if oResultado:OWSERROS <> NIL
		Aadd(aErro,STR0008) //"Erros no XML"
		For nX := 1 To Len(oResultado:OWSERROS:OWSERRO)
			Aadd(aErro,STR0001 + oResultado:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
			Aadd(aErro,STR0002+ oResultado:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
		Next nX
		FINXRESLog("RD0",STR0014,"",aErro) //"Exclusao de Participantes"
		aPassageiro := {}
	endif

endif

for nX := 1 to Len(aPassageiro)
	dbSelectArea("RD0")
	dbGoto(aPassageiro[nX][2])
	Reclock("RD0",.F.)
	RD0->RD0_RESERV := '0' // Pendente de Atualiza็ใo para se incluido na filial correta
	MsUnlock()
next

RestArea(aAreaRd0)

Return Len(aErro)= 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN657IniDeบAutor  ณMicrosiga           บ Data ณ  09/26/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static function FN657INIDel()

local oFiltros := Usuarios_Filtros():New
oFiltros:oWSTipoConsultaIdentificador := Usuarios_TipoIdentificador():New()
oFiltros:oWSTipoConsultaIdentificador:Value := "2"
oFiltros:oWSLogins := Usuarios_ArrayOfString3():New()
oFiltros:oWSLogins:cLogin := {}
oFiltros:oWSCODEmpresas  := Usuarios_ArrayOfString():New()
oFiltros:oWSCODEmpresas:cCODEmpresa  := {}
oFiltros:oWSTipoRequisicao := Usuarios_TipoRequisicao():New()
oFiltros:oWSTipoRequisicao:Value := "0"
oFiltros:oWSNivelAutorizacao := Usuarios_NivelAutorizacao():New()
oFiltros:oWSNivelAutorizacao:Value := "0"
oFiltros:oWSServicoTipo      := Usuarios_ServicoTipo():New()
oFiltros:oWSServicoTipo:Value := "0"
oFiltros:oWSServicoArea      := Usuarios_ServicoArea():New()
oFiltros:oWSServicoArea:Value := "0"
oFiltros:lAtivo := .T.
oFiltros:oWSTipoPax  := Usuarios_TipoPax():New()
oFiltros:oWSTipoPax:Value := '0'

Return oFiltros

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657TraบAutor  ณAlexandre Circenis  บ Data ณ  09/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao executada a partir do cadastro de participantes para บฑฑ
ฑฑบ          ณintegracao com o Sistema Reserve                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA657TRN(cEmp, cFil)
default cEmp := cEmpAnt
default cFil := cFilAnt

if !RD0->RD0_DVIAGE $ " 1" .and. !Empty(RD0->RD0_LOGINR) // Eh viajante e tem Login Cadastrado
	MsgRun(STR0011,STR0012,{|| FINA657Int(cEmp, cFil,.T.)}) //"Integrando com o Sistema Reserve"###"Integra็ใo Reserve"
endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINA657TRNบAutor  ณAlexandre Circenis  บ Data ณ  09/20/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a Transferencia de Particitantes                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINA657PTR(cEmp, cFil)

Local oSvc		:= Nil
Local cSessao	:= "" 

Default cEmp := ''
Default cFil := ''

dbSelectArea("RD0")
	
If FINXRESOSe(@cSessao,@oSvc,"RD0")                          
	
	FN657Trans(cSessao)
	FINXRESCSe(cSessao,oSvc)
	
Endif

Return
      
Static Function FN657Trans(cSessao)
Local oUsers := WSUsuarios():New()
Local aDel
Local aPax			:= {}
Local lTrans := .T.
Local cSessao2 := ''
Local oSvc2

// Se houver filial e empresa anterior do participante
// Devemos excluir do reserve	
if !Empty(RD0->RD0_FILANT) .and. !Empty(RD0->RD0_EMPANT)
 
	if BKO2Lic(RD0->(RD0_EMPANT+RD0_FILANT)) <> BKO2Lic()// O Licenciado ้ diferente do atual
		cFilOld := cFilAnt
		cFilAnt := RD0->RD0_FILANT
		cEmpOld := cEmpAnt
		cEmpAnt := RD0->RD0_EMPANT
		lTrans  := FINXRESOSe(@cSessao2,@oSvc2,"RD0")
		cFilAnt := cFilOld
		cEmpAnt := cEmpOld
		
	endif
	if lTrans 	
		oUsers:OWSEXCLUIRRQ:CSESSAO := if(!Empty(cSessao2), cSessao2, cSessao)
		oUsers:OWSEXCLUIRRQ:OWSFILTROS := FN657INIDel()
		aDel := {AllTrim(RD0->RD0_LOGINR)}
		aAdd(aPax, {Val(RD0->RD0_IDRESE),RD0->(Recno())})
		oUsers:OWSEXCLUIRRQ:OWSFILTROS:oWSLogins:cLogin := aDel
		oUsers:Excluir()
		lTrans := Fina657Tra(oUsers:oWSExcluirResult, aPax)
	   	RecLock("RD0",.F.)
	   	RD0->RD0_RESERV := "0"
	   	msUnlock()
	   	if !Empty(cSessao2)
		   	FINXRESCSe(cSessao2,oSvc2)
		endif
	endif

	if lTrans // Pode prosseguir com a transferencia       
	 	if BKO2Lic(RD0->(RD0_EMPATU+RD0_FILATU)) <> BKO2Lic()// O Licenciado ้ diferente do atual
			cFilOld := cFilAnt
			cFilAnt := RD0->RD0_FILATU
			cEmpOld := cEmpAnt
			cEmpAnt := RD0->RD0_EMPATU
			lTrans  := FINXRESOSe(@cSessao2,@oSvc2,"RD0")
			cFilAnt := cFilOld
			cEmpAnt := cEmpOld
		endif
  	
		oUsers	:= WSUsuarios():New()
		oUsers:oWSAtualizarRQ:CSESSAO := if(!Empty(cSessao2), cSessao2, cSessao)
		oUsers:oWSAtualizarRQ:oWSCadastros := Usuarios_ArrayOfDados():New()
		Aadd(oUsers:oWSAtualizarRQ:oWSCadastros:oWSDados, FINA657USE(cEmpAnt,cFilAnt))
		oUsers:Atualizar()
		FINA657PRO(oUsers:OWSATUALIZARRESULT) // Processa o resultado do manuten็ใo dos usuarios no Reserve
        FN657Conf(oUsers, cSessao)
        
	   	if !Empty(cSessao2)
		   	FINXRESCSe(cSessao2,oSvc2)
		endif
		
	endif			
endif

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN657Conf บAutor  ณMicrosiga           บ Data ณ  09/27/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Confirma a atualiza็ใo do aprovador                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FN657Conf(oUsers, cSessao)

oUsers:oWSAtualizarAutorizadorRQ := Usuarios_AtualizarAutorizadorRQ():New()
oUsers:oWSAtualizarAutorizadorRQ:cSessao := cSessao
oUsers:oWSAtualizarAutorizadorRQ:oWSTipoIdentificador := Usuarios_TipoIdentificador():New()
oUsers:oWSAtualizarAutorizadorRQ:oWSTipoIdentificador:Value := "1"
oUsers:AtualizarAutorizador()
Fn657ProAu(oUsers:OWSATUALIZARAUTORIZADORRESULT)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFN657ProAuบAutor  ณMicrosiga           บ Data ณ  09/27/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณProcessa a confirma็ใo do autorizador                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Fn657ProAu(oResultado)
Local aUsuarios
Local nX := 0
Local nY := 0
Local cStatus := '0' // Transferido pendende de inclusao na nova empresa
Local aAreaRd0 := RD0->(GetArea())
Local aErro :={}
Local aPax

/*BEGINDOC
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiveis Status         ณ
//ณ0 - Nใo Enviado         ณ
//ณ1 - Incluido com Sucessoณ
//ณ2 - Nใo Incluido        ณ
//ณ3 - Usuario com Erro    ณ
//ณ4 - Passageiro com erro ณ
//ณ5 - Ambos com Erro      ณ
//ณ6 - Pendente de Transferณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DOC*/

RD0->(dbSetOrder(1))

if aUsuarios := oResultado:OWSPASSAGEIROS <> NIL
	
	aPax      := oResultado:OWSPASSAGEIROS
	if aPax <> NIL .and. Len(aPax:oWSCadastro) > 0
		// Processamento do Resultado da Exclusao solicitada ao reserve
		for nY := 1 TO Len(aPax:oWSCadastro)
			cStatus := '1'			
			if aPax:oWSCadastro[nY]:OWSERROS <> NIL .and. Len(aPax:oWSCadastro[nY]:OWSERROS:OWSERRO) > 0
				Aadd(aErro,STR0015) //"Erros na Confirma็ใo de Autorizador"
				Aadd(aErro,STR0016+aPax:oWSCadastro[nY]:cMatricula) //"Participante Matricula :"
				For nX := 1 To Len(aPax:oWSCadastro[nY]:OWSERROS:OWSERRO)
					Aadd(aErro,STR0001 + aPax:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CCODERRO) //"CCODERRO: "
					Aadd(aErro,STR0002+ aPax:oWSCadastro[nY]:OWSERROS:OWSERRO[nX]:CMENSAGEM) //"CMENSAGEM: "
				Next nX  
				FINXRESLog("RD0",STR0017,"",aErro) //"Confirmacao de Autorizador"
			endif
			if Len(aErro) > 0
				dbSelectArea("RD0")
				dbSeek(xFilial("RD0")+aPax:oWSCadastro[nY]:cMatricula)
				RecLock("RD0",.F.)
				RD0->RD0_RESERV := '0' // Pendente de Atualiza็ใo do Autorizador
				msUnlock() 
			endif
			aErro := {}
		next nY			
	endif
	
endif

RestArea(aAreaRd0)

Return
