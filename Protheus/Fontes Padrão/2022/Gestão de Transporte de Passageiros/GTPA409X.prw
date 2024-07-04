#Include "GTPA409X.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH" 
#include "PARMTYPE.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTP409ConfVei
	Valida Conflitos do veiculo
@author Fernando Amorim(Cafu)
@param  cCodVei = Codigo do Veículo
        dDtIni  = Data inicio da viagem
        dDtFim  = Data final da viagem
        cRetLog = retorna o log quando o retorno for falso. Passar uma variavel com @ para pegar esse retorno.
@return lRet   .T. ou .F.
@since		21/07/2017       
@version	P12
/*/
//------------------------------------------------------------------------------
Function GTP409ConfVei(cCodVei,dDtInit,dDtFinal,cRetLog,cHrIni,cHrFim,cLinha,cMsgSol,lShowMsg)
Local lRet          := .T.
Local dDtIni        := nil
Local dDtFim        := nil

Local aErro			:= {}

Default dDtInit     := dDatabase
Default dDtFinal    := dDatabase
Default cRetLog     := ''
Default cHrIni      := ''
Default cHrFim      := ''
Default cLinha		:= ""
Default lShowMsg	:= .T.

dDtIni		:= DtoS(dDtInit)
dDtFim		:= DtoS(dDtFinal)
cHrIni		:= Transform(cHrIni,'@R 99:99')
cHrFim		:= Transform(cHrFim,'@R 99:99')
    
/* 
//Aguardando função a ser disponibilizada pelo SIGAMNT
If Len(aDadosMnt) > 0

    For nX := 1 To Len(aDadosMnt)
        //Validar campos enviados pela função a ser disponibilizada pelo SIGAMNT
        lRet := .F.
    Next 
Endif
*/
//Alterado por Fernando Radu em 01/08/2022 
//- Ajuste efetuado para passar parâmetro cLinha
If lRet .and. !GTPVldDocRec('2',cCodVei,dDtFinal,cLinha)

    lRet    := .F.
	//Alterado por Fernando Radu em 02/08/2022 - ajuste para trazer a mensagem
	//que foi criada a partir da função GTPVldDocRec(..)
	aErro := DocErrorMessage()

    cRetLog := aErro[1][1]	//I18n(STR0023,{cCodVei})//"O Veículo #1 possuí documentos vencidos, verifique o cadastro de Documentos de Veículos"
	cMsgSol := aErro[1][2]

Endif

//Alterado por Fernando Radu em 02/08/2022
//Verifica se será apresentada a mensagem, internamente por 
//esta função - lShowMsg igual a .T.
//também foi passado o parâmetro de solução para a mensagem FwAlertHelp(..) 
IF ( lShowMsg .And. !Empty(cRetLog) )
	FwALertHelp(cRetLog,cMsgSol,"GTP409ConfVei")	
EndIF	

return lRet	

/*/{Protheus.doc} GTP409ColConf
Valida Conflitos do Colaboradores
@type function
@author Fernando Amorim(Cafu)
@since 27/07/2017      
@version 1.0
@param cCodCol, character, (Descrição do parâmetro)
@param dDtRef, data, (Descrição do parâmetro)
@param cLinha, character, (Descrição do parâmetro)
@param aConf, array, Array com a operação a ser avaliada. ({'1','2','3','4','5','6','7','8','9'})
@param aRetLog, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTP409ColConf(cCodCol,dDtRef,cLinha,aConf,aRetLog)
              
Local lRet			:= .T.
Local lTipoMoto		:= .F.
Local lTodos		:= .T.

Local aError		:= {}

Default dDtRef		:= dDatabase
Default cLinha		:= ''
Default aConf		:= {}
Default aRetLog		:= {}

If Empty(dDtRef) 
	dDtRef		:= dDatabase
Endif

aRetLog := aSize(aRetLog,3)
aRetLog[1] := ""
aRetLog[2] := ""
aRetLog[3] := ""

lTodos := ValType(aConf) == "A" .And. Len(aConf) == 0
			
//Validações de Colaboradores - Início	
GYG->(DbSetOrder(1))

If ( GYG->(DbSeek(XFilial("GYG") + cCodCol)) )

    If ( aScan(aConf,"0")  > 0  .Or. lTodos  ) .and. !GTPVldDocRec('1',cCodCol,dDtRef,cLinha)
        
		lRet    := .F.
		
		aError := DocErrorMessage()
        
		If ( Len(aError) > 0 )

			aRetLog[1] := "0"
			aRetLog[2] := aError[1][1]	//Erro		//I18n(STR0024,{cCodCol})//"O Colaborador #1 possuí documentos vencidos, verifique o cadastro de Documentos de Colaboradores"
			aRetLog[3] := aError[1][2]	//Solução
		
		EndIf
	Endif

	If lRet	// Valida Cargo
		IF !VldEtilom(cCodCol,dDtRef)
			aRetLog[1] := "9"
			aRetLog[2] := STR0025	//"Escolha outro recurso, este recurso esta bloqueado por Etilômetro."
			lRet 	:= .F.
		EndIf
	EndIf

	SRA->(DbSetOrder(1))
	
	If ( SRA->(DbSeek(GYG->GYG_FILSRA + GYG->GYG_FUNCIO)) )		
		
		//Verifica se o colaborador não está afastado ou demitido
		If ( SRA->RA_SITFOLH == "D"  .And. ( aScan(aConf,"1")  > 0  .Or. lTodos  ) )
			aRetLog[1] := "1"
			aRetLog[2] := STR0006 //"Colaborador foi demitido. Selecione outro colaborador ou ajuste o seu cadastro de funcionário."  
			lRet := .F.
		ElseIf DTOS(SRA->RA_ADMISSA) > DTOS(dDtRef) .AND. ( aScan(aConf,"3") .Or. lTodos)
			aRetLog[1] := "0"
			aRetLog[2] := "Data de admissão do colaborador maior do que a data informada."
			lRet := .F.
		ElseIf Ga409xColFer(GYG->GYG_FILSRA,SRA->RA_MAT,dDtRef) .AND. ( aScan(aConf,"3")  > 0  .Or. lTodos  )
			
			aRetLog[1] := "3"
			aRetLog[2] := STR0008 //"Colaborador está de férias. Selecione outro colaborador ou ajuste o seu cadastro de funcionário."
			lRet := .f.
			
		ElseIf ( VldAfastmt(GYG->GYG_FILSRA,SRA->RA_MAT,DtoS(dDtRef)) .And. ( aScan(aConf,"2")  > 0  .Or. lTodos  ) )
			
			aRetLog[1] := "2"
			aRetLog[2] := STR0007 //	"Colaborador está afastado. Selecione outro colaborador ou ajuste o seu cadastro de funcionário."
			lRet := .f.
										
		Else
			//Somente para colaboradores motoristas
			If Posicione("GYK",1,xFilial("GYK") + GYG->GYG_RECCOD,'GYK_VALCNH') == '1'
				lTipoMoto := VldtpMoto(GYG->GYG_RECCOD,cLinha)
			EndIF
			
			If lTipoMoto .And. ( aScan(aConf,"4")  > 0  .Or. lTodos  ) 
								
				If ( !Empty(SRA->RA_DTVCCNH) )
				
					//Carteira de Motorista Vencida a 30 dias ou menos
					If ( dDtRef >= SRA->RA_DTVCCNH .and. dDtRef - SRA->RA_DTVCCNH <= 30 ) 
						
						lRet := MsgYesNo(STR0009 ) //"A validade da carteira de motorista expirou, mas ainda está dentro do prazo de 30 dias. Deseja manter o colaborador escolhido?")
					
					//Carteira de Motorista Vencida a mais de 30 dias
					ElseIf (SRA->RA_DTVCCNH + 30) < dDtRef
						aRetLog[1] := "4"
						aRetLog[2] := STR0010 //"Escolha outro recurso, não é permitido um motorista com habilitação vencida. A validade da carteira de motorista está expirada há mais de 30 dias."
						lRet := .f.
					Endif
				
				Endif
			EndIf
				
			If lRet .And.  ( aScan(aConf,"5")  > 0  .Or. lTodos  ) 
				// Valida Turno
				If !VldTurno(SRA->RA_TNOTRAB,GYG->GYG_RECCOD,cLinha)
					aRetLog[1] := "5"
					aRetLog[2] := STR0011	//"Escolha outro recurso, este motorista não está no mesmo turno da linha."
					lRet 	:= .F.
				Endif
			EndIf
			
			If lRet .And. ( aScan(aConf,"6")  > 0  .Or. lTodos  ) 
				// Valida Curso
				If !VldCurso(SRA->RA_MAT,GYG->GYG_RECCOD,cLinha)
					aRetLog[1] := "6"
					aRetLog[2] := STR0012	//"Escolha outro recurso, este motorista não tem o curso necessário para essa linha."
					lRet 	:= .F.
				Endif
			Endif	

			If lRet .And. ( aScan(aConf,"7")  > 0  .Or. lTodos  ) 
				// Valida habilidades
				If !VldHabil(SRA->RA_MAT,GYG->GYG_RECCOD,cLinha)
					aRetLog[1] := "7"
					aRetLog[2] := STR0013	//"Escolha outro recurso, este motorista não tem a habilidade necessária para essa linha."
					lRet 	:= .F.
				Endif
			Endif

			If lRet .And. ( aScan(aConf,"8")  > 0  .Or. lTodos  ) 
				// Valida Função
				If !VldFuncao(SRA->RA_MAT,GYG->GYG_RECCOD,cLinha,SRA->RA_CODFUNC)
					aRetLog[1] := "8"
					aRetLog[2] := STR0016	//"Escolha outro recurso, este recurso não possuí a função necessária para essa linha."
					lRet 	:= .F.
				Endif
			EndIf

			If lRet .And. ( aScan(aConf,"9")  > 0  .Or. lTodos  ) 
				// Valida Cargo
				If !VldCargo(SRA->RA_MAT,GYG->GYG_RECCOD,cLinha,SRA->RA_CODFUNC)
					aRetLog[1] := "9"
					aRetLog[2] := STR0017	//"Escolha outro recurso, este recurso não possuí o cargo necessário para essa linha."
					lRet 	:= .F.
				Endif
			EndIf
		 Endif
	Endif			
Endif
					
return( lRet )

/*/{Protheus.doc} VldAfastmt
(long_description)
@type function
@author henrique.toyada
@since 27/11/2018
@version 1.0
@param cFilMatr, character, (Filial do funcionário (RH))
@param cCodMatr, character, (Matricula do funcionário (RH))
@param dDtRef, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldAfastmt(cFilMatr,cCodMatr,dDtRef)

Local lRet := .F.
Local cNxtAlias := GetNextAlias()

Default cCodMatr := ""
Default cFilMatr := ""

BeginSQL Alias cNxtAlias

	SELECT Count(SR8.R8_MAT) as TOTAL 
	FROM %Table:SR8% SR8 
	INNER JOIN %Table:SRA% SRA
		ON SRA.%NotDel%
		AND SRA.RA_FILIAL = SR8.R8_FILIAL
		AND SRA.RA_MAT = SR8.R8_MAT
		AND SRA.RA_SITFOLH IN ('A',' ','F')
	WHERE SR8.%NotDel%
		AND SR8.R8_FILIAL = %Exp:cFilMatr%
		AND SR8.R8_MAT = %Exp:cCodMatr%
		AND (
				(SR8.R8_DATAFIM <> '' AND %Exp:dDtRef% BETWEEN SR8.R8_DATAINI AND SR8.R8_DATAFIM)
				OR (SR8.R8_DATAFIM = '' AND %Exp:dDtRef% >= SR8.R8_DATAINI)
			)
	
EndSQL

lRet := (cNxtAlias)->TOTAL > 0

(cNxtAlias)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldtpMoto
	Verifica se é motorista e se ta na linha esse tipo de recurso
@author Fernando Amorim(Cafu)
return lRet   .T. ou .F.
@since		28/07/2017       
@version	P12
/*/
Function VldtpMoto(cTpCol,cLinha)
Local lRet			:= .F.
Local cAlias		:= ''
 
cAlias := GetNextAlias()
								
BeginSQL Alias cAlias
	
SELECT
	1 EXISTE
FROM
	%Table:GYM% GYM
WHERE
	GYM_FILIAL = %XFilial:GYM%
	AND GYM_CODENT = %Exp:cLinha%
	AND GYM_RECCOD = %Exp:cTpCol% 
	AND GYM.%NotDel%

EndSQL

If (cAlias)->EXISTE > 0
	lRet := .T.
Endif

(cAlias)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldTurno
	Verifica se o turno do  motorista e da linha alinham
@author Fernando Amorim(Cafu)
return lRet   .T. ou .F.
@since		28/07/2017       
@version	P12
/*/
Function VldTurno(cTurCol,cTpCol,cLinha)

Local lRet			:= .F.
Local cAlias		:= ''
 
If VldGYJ(1,cTpCol,cLinha)
	cAlias := GetNextAlias()
									
	BeginSQL Alias cAlias
		
	SELECT
		1 EXISTE
	FROM
		%Table:GYJ% GYJ
	INNER JOIN
		%Table:GYM% GYM	
	ON
		GYJ_FILIAL = GYM_FILIAL
		AND GYJ_CODGYM = GYM_CODIGO
		AND GYM_CODENT = %Exp:cLinha%
		AND GYM_RECCOD = %Exp:cTpCol% 
		AND GYM.%NotDel%
	WHERE
		GYJ_FILIAL = %XFilial:GYJ%
		AND GYJ_CHAVE = %Exp:cTurCol%
		AND GYJ_TIPO = 1
		AND GYJ.%NotDel%
	
	EndSQL
		
	If (cAlias)->EXISTE > 0
		lRet := .T.
	Endif
	
	(cAlias)->(DbCloseArea())

Else
	lRet := .T.
EndIf

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldCurso
	Verifica se o Curso do  motorista e da linha alinham
@author Fernando Amorim(Cafu)
return lRet   .T. ou .F.
@since		28/07/2017       
@version	P12
/*/
Function VldCurso(cMat,cTpCol,cLinha)
Local lRet			:= .F.
Local cAlias		:= ''

If VldGYJ(4,cTpCol,cLinha)
 
	cAlias := GetNextAlias()
									
	BeginSQL Alias cAlias
		
	SELECT
		1 EXISTE
	FROM
		%Table:GYJ% GYJ
	INNER JOIN
		%Table:GYM% GYM	
	ON
		GYJ_FILIAL = GYM_FILIAL
		AND GYJ_CODGYM = GYM_CODIGO
		AND GYM_CODENT = %Exp:cLinha%
		AND GYM_RECCOD = %Exp:cTpCol% 
		AND GYM.%NotDel%
	INNER JOIN
		%Table:RA4% RA4	
	ON
		RA4_FILIAL = %XFilial:RA4%
		AND GYJ_CHAVE = RA4_CURSO
		AND RA4_MAT = %Exp:cMat%
		AND RA4.%NotDel%
	
	WHERE
		GYJ_FILIAL = %XFilial:GYJ%
		AND GYJ_TIPO = 4
		AND GYJ.%NotDel%
	
	EndSQL
		
	If (cAlias)->EXISTE > 0
		lRet := .T.
	Endif
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .T.
Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldHabil
	Verifica se o habilidades do  motorista e da linha alinham
@author Fernando Amorim(Cafu)
return lRet   .T. ou .F.
@since		28/07/2017       
@version	P12
/*/
Function VldHabil(cMat,cTpCol,cLinha)
Local lRet			:= .F.
Local cAlias		:= ''

If VldGYJ(5,cTpCol,cLinha) 
 
	cAlias := GetNextAlias()
									
	BeginSQL Alias cAlias
		
	SELECT
		1 EXISTE
	FROM
		%Table:GYJ% GYJ
	INNER JOIN
		%Table:GYM% GYM	
	ON
		GYJ_FILIAL = GYM_FILIAL
		AND GYJ_CODGYM = GYM_CODIGO
		AND GYM_CODENT = %Exp:cLinha%
		AND GYM_RECCOD = %Exp:cTpCol% 
		AND GYM.%NotDel%
	INNER JOIN
		%Table:RBI% RBI	
	ON
		RBI_FILIAL = %XFilial:RBI%
		AND GYJ_CHAVE = RBI_HABIL
		AND RBI_MAT = %Exp:cMat%
		AND RBI.%NotDel%
	
	WHERE
		GYJ_FILIAL = %XFilial:GYJ%
		AND GYJ_TIPO = 5
		AND GYJ.%NotDel%
	
	EndSQL
		
	If (cAlias)->EXISTE > 0
		lRet := .T.
	Endif
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .T.
Endif

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} VldGYJ
	Verifica se o habilidades do  motorista e da linha alinham
@author Fernando Amorim(Cafu)
return lRet   .T. ou .F.
@since		28/07/2017       
@version	P12
/*/
Function VldGYJ(nTp,cTpCol,cLinha)
Local lRet	 := .F.
Local cAlias := ''
Local cTp    := cValToChar(nTp)

cAlias := GetNextAlias()
								
BeginSQL Alias cAlias

SELECT
	1 EXISTE
FROM
	%Table:GYJ% GYJ
INNER JOIN
	%Table:GYM% GYM	
ON
	GYJ_FILIAL = GYM_FILIAL
	AND GYJ_CODGYM = GYM_CODIGO
	AND GYM_CODENT = %Exp:cLinha%
	AND GYM_RECCOD = %Exp:cTpCol% 
	AND GYM.%NotDel%
	
WHERE
	GYJ_FILIAL = %XFilial:GYJ%
	AND GYJ_TIPO = %Exp:cTp%
	AND GYJ.%NotDel%

EndSQL

If (cAlias)->EXISTE > 0
	lRet := .T.
Endif

(cAlias)->(DbCloseArea())

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldFuncao
Verifica se a Função do Colaborador e da linha se alinham

@Param	cMat	= Matricula do Colaborador.
@Param	cTpCol 	= Tipo do Colaborador
@Param	cLinha 	= Código da Linha de Acordo com a Escala Informada.
@Param 	cFunc	= Código da Função do Funcionário

@return lRet   .T. ou .F.

@author		Mick William da Silva
@since		21/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function VldFuncao(cMat,cTpCol,cLinha,cFunc)
Local lRet			:= .F.
Local cAlias		:= ''

Default cFunc 		:= ''

If VldGYJ(2,cTpCol,cLinha) 
 
	cAlias := GetNextAlias()
									
	BeginSQL Alias cAlias
		
	SELECT
		1 EXISTE
	FROM
		%Table:GYJ% GYJ
	INNER JOIN
		%Table:GYM% GYM	
	ON
		GYJ_FILIAL = GYM_FILIAL
		AND GYJ_CODGYM = GYM_CODIGO
		AND GYM_CODENT = %Exp:cLinha%
		AND GYM_RECCOD = %Exp:cTpCol% 
		AND GYM.%NotDel%
	WHERE
		GYJ_FILIAL = %XFilial:GYJ%
		AND GYJ_TIPO = 2
		AND GYJ_CHAVE = %Exp:cFunc%
		AND GYJ.%NotDel%
	
	EndSQL
		
	If (cAlias)->EXISTE > 0
		lRet := .T.
	Endif
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .T.
Endif

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldCargo
Verifica se o Cargo do Colaborador e da linha se alinham

@Param	cMat	= Matricula do Colaborador.
@Param	cTpCol 	= Tipo do Colaborador
@Param	cLinha 	= Código da Linha de Acordo com a Escala Informada.
@Param 	cFunc	= Código da Função do Funcionário
@return lRet   .T. ou .F.

@author		Mick William da Silva
@since		21/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function VldCargo(cMat,cTpCol,cLinha,cFunc)
Local lRet			:= .F.
Local cAlias		:= ''
Local cCargo		:= '' 

Default cFunc 		:= ''

If VldGYJ(3,cTpCol,cLinha) 

	cCargo := Posicione("SRJ",1,xFilial("SRJ") + cFunc,'RJ_CARGO') 
	
	cAlias := GetNextAlias()
									
	BeginSQL Alias cAlias
		
	SELECT
		1 EXISTE
	FROM
		%Table:GYJ% GYJ
	INNER JOIN
		%Table:GYM% GYM	
	ON
		GYJ_FILIAL = GYM_FILIAL
		AND GYJ_CODGYM = GYM_CODIGO
		AND GYM_CODENT = %Exp:cLinha%
		AND GYM_RECCOD = %Exp:cTpCol% 
		AND GYM.%NotDel%
	WHERE
		GYJ_FILIAL = %XFilial:GYJ%
		AND GYJ_TIPO = 3
		AND GYJ_CHAVE = %Exp:cCargo%
		AND GYJ.%NotDel%
	
	EndSQL
		
	If (cAlias)->EXISTE > 0
		lRet := .T.
	Endif
	
	(cAlias)->(DbCloseArea())
	
Else
	lRet := .T.
Endif

Return lRet



/*/{Protheus.doc} Ga409xColFer
(long_description)
@type function
@author henrique.toyada
@since 05/02/2019
@version 1.0
@param cFilSRH, character, (Descrição do parâmetro)
@param cMatricula, character, (Descrição do parâmetro)
@param dDtRef, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function Ga409xColFer(cFilSRH,cMatricula,dDtRef)
Local lRet			:= .F.
Local cQryAlias		:= GetNextAlias()

Default cFilSRH		:= xFilial('SRH')
Default cMatricula	:= ""
Default dDtRef		:= dDataBase
 
	BeginSql Alias cQryAlias
		SELECT Count(*) as TOTAL 
		FROM %Table:SRH% SRH
		INNER JOIN %Table:SRA% SRA
			ON SRA.%NotDel%
			AND SRA.RA_FILIAL = SRH.RH_FILIAL
			AND SRA.RA_MAT = SRH.RH_MAT
		WHERE 
			SRH.RH_FILIAL = %Exp:cFilSRH%
			AND SRH.RH_MAT = %Exp:cMatricula%
			AND %Exp:DtoS(dDtRef)% BETWEEN SRH.RH_DATAINI AND SRH.RH_DATAFIM
			AND SRH.%NotDel%
	EndSql
	
	lRet	:= (cQryAlias)->TOTAL > 0
	
	(cQryAlias)->(DbCloseArea())
	
Return lRet

/*/{Protheus.doc} Ga409xColD
//Verifica se o colaborador está demitido - valid do colaborador, escala de plantão.
@type function
@author antenor.silva
@since 07/02/2019
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function Ga409xColD(cCodCol)
Local aArea	:= GetArea()
Local lRet	:= .T.

GYG->(DbSetorder(1))
If (GYG->(DbSeek(xFilial("GYG")+cCodCol)))
	
	SRA->(DbSetOrder(1))
	If (SRA->(DbSeek(GYG->GYG_FILSRA+GYG->GYG_FUNCIO)))
		If SRA->RA_SITFOLH == "D"
			Help( ,, 'Help','GTPA409X', STR0018, 1, 0,,,,,,{STR0019} )
			lRet := .F.
		EndIf
	EndIf
	
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} VldEtilom
//Verifica se o colaborador está com valor de etilometro maior que zero
@type function
@author GTP
@since 19/10/2020
@version 1.0
@param cCodCol, character, (Descrição do colaborador)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldEtilom(cCodCol,dDtRef)
Local lRet := .T.
Local aAreaAux := {}
Local cCodColab :=  ''
Local cAliasTmp		:= GetNextAlias()

If (GTPxVldDic('GQO', , .T., .F.))
  	
	aAreaAux 	:= GQO->(GetArea())
	cCodColab 	:= SubStr(cCodCol,1,TamSx3("GQO_CODIGO")[1])

	BeginSql Alias cAliasTmp
	 		
		SELECT GQO_CODIGO,GQO_DATA,GQO_BLOQUE
	 	FROM %Table:GQO% GQO
		WHERE
		GQO.GQO_FILIAL = %xFilial:GQO% AND
		GQO_CODIGO = %Exp:cCodColab% AND
		%Exp:dDtRef% >= GQO_DATA AND
		GQO_BLOQUE = '1' AND
		GQO_MSBLQL = '2' AND
		GQO.%NotDel%
			      
	EndSql

	If (cAliasTmp)->(!Eof())
		lRet := .F.  
	EndIf
	(cAliasTmp)->(DbCloseArea())

	RestArea(aAreaAux)

EndIf

Return lRet
