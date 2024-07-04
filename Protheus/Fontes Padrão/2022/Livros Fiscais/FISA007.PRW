#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA007

Rotina de geração do arquivo texto da EFD Contribuições.
O arquivo será gerado através desta rotina, utilizando as classes disponibilizadas
para esta obrigação. Aqui teremos query das operações, e irá gerenciar as chamadas
para geração do arquivo.
@author Erick G. Dias
@since 02/04/2014
@version 11.80
@description teste descrição

/*/
//-------------------------------------------------------------------
Function FISA007()

STATIC PIS			:= '1'
STATIC COFINS		:= '2'
STATIC CREDITO		:= '1'
STATIC DEBITO		:= '2'
Static lSPDFIS11	:= ExistBlock("SPDFIS11")

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IndMovto()
@description Função para verificar indicador de movimento do documento.

@param	cTpMov,String,Indica se documento é entrada=E ou saída=S
@return cIndMovto,String,1=Nf entrada, 2= NF saída
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function IndMovto(cTpMov )
Return Iif ("E"$cTpMov, "1", "2")


//-------------------------------------------------------------------
/*/{Protheus.doc} IndEmit()
@description Função para verificar o indicador de emissão do documentos,
			   baseando-se no indicador de formulário próprio do livro
			   e se é documento de saída ou entrada.
@param	cFormProp,String,Indica se documento é formulário próprio S=Sim/N=Não
@param	cFormProp,String,Indica se é documento de 1==Entrada ou 2 ==Saída
@return cIndEmit,String,1=Emissão de terceiros/2=Emissão própria
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function IndEmit(cFormProp, cEntSai)
Local cIndEmit	:= ''
If (Empty (cFormProp)) .And. cEntSai=="1"
	//Documento de entrada com sem formulário próprio é emissão de terceiros
	cIndEmit := "1"
ElseIf (Empty (cFormProp)) .And. cEntSai=="2"
	//Documento de saída sem formulário próprio é emissão própria
	cIndEmit := "0"
Else
	If ("S"$cFormProp)
		//Se estiver preenchido como formulário próprio será emissão própria
		cIndEmit := "0"
	Else
		//Se não estiver preenchido como formulário próprio será emissão de terceiros
		cIndEmit := "1"
	EndIf
EndIf

Return cIndEmit

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCL2()
@description Função que irá fazer query na tabela Cl2 para buscar as informações
			   do registro F100, F120, F130, F111, F129 e F139 gravados pela apuração.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoF010,String,Relação com registro pai F010.
@author Erick G. Dias
@since 06/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcCL2(dDataDe, dDataAte, cGrupoF010,oTabela,aNumeracao,oBloco1,oBloco0,lConcFil,c0140,lRgCmpCons,oBlocoF,lCL2Alias,lCl2Clifor, lCl2Loja)

Local cAliasCL2	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cConta		:= ''
Local cCusto		:= ''
Local cPart		:= ''
Local cLoja		:= ''
Local cAlsSA		:= ''
Local cCod0150	:= ''
Local cCodProd	:= ''
Local aParF550	:= {}
Local nICMPAD 	:= 	GetNewPar("MV_ICMPAD",18)
Local lF130Grp	:= SuperGetMv("MV_F130GRP",.F.,.F.)
Local lF130		:= .F.
Local lBsPIS	:= .T.
Local lBsCOF	:= .T.
Default lCl2Clifor	:= .F.
Default lCl2Loja	:= .F.

oBlocoF:setaNumer(aNumeracao)

cCampos	:= '%CL2.CL2_INDOP	, CL2.CL2_PARTI	, CL2.CL2_PART	, CL2.CL2_DTOPER	, CL2.CL2_VLOPER	, CL2.CL2_CSTPIS,'
cCampos	+= 'CL2.CL2_BCPIS		, CL2.CL2_ALQPIS	, CL2.CL2_VLPIS	, CL2.CL2_CSTCOF	, CL2.CL2_BCCOF, '
cCampos	+= 'CL2.CL2_ALQCOF	, CL2.CL2_VLCOF	, CL2.CL2_CODBCC	, CL2.CL2_ORICRD	, CL2.CL2_CTA, '
cCampos	+= 'CL2.CL2_CCUS		, CL2.CL2_DESCR	, CL2.CL2_REG		, CL2.CL2_MESANO  , CL2.CL2_VLAQUI,'
cCampos	+= 'CL2.CL2_INDPAC	, CL2.CL2_IDBEM	, CL2.CL2_IDUTI	, CL2.CL2_VLPARC	, CL2.CL2_VLEXCL, CL2.CL2_ITEM,'
cCampos	+= 'CL2.CL2_NUMPRO	, CL2.CL2_INDPRO  , CL2.CL2_INDCRD'

IF lCl2Clifor .AND. lCl2Loja
	cCampos	+= ',CL2.CL2_CLIFOR	, CL2.CL2_LOJA'
EndIF
IF lCL2Alias
	cCampos	+= ',CL2_ALIAS'
EndIF

cCampos	+= '%'

cFiltro 	:= "%"
cFiltro 	+= "CL2.CL2_FILIAL= '"+ xFilial('CL2')+ "' AND "
cFiltro 	+= "CL2.CL2_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CL2.CL2_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "

If lRgCmpCons
	cFiltro 	+= "CL2.CL2_REG = 'F100' AND "
	cFiltro 	+= "(CL2.CL2_INDOP = '1' or CL2.CL2_INDOP = '2')  AND "
EndIF

cFiltro 	+= "%"

cAliasCL2	:=	GetNextAlias()
BeginSql Alias cAliasCL2

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL2% CL2
	WHERE
	%Exp:cFiltro%
	CL2.%NotDel%

EndSql
DbSelectArea (cAliasCL2)
(cAliasCL2)->(DbGoTop ())

TcSetField(cAliasCL2,"CL2_DTOPER","D",8,0)

oBlocoF:setaNumer(@aNumeracao)
 
Do While !(cAliasCL2)->(Eof ())
	//IRÁ GERAR REGISTRO F100 - DEMAIS DOCUMENTOS E OPERAÇÕES
	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasCL2)->CL2_CTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)
	cCusto	:= FSA0080600('',oBloco0,oTabela,lConcFil,SubStr((cAliasCL2)->CL2_CCUS,1,TAMSX3("CTT_CUSTO")[1]))
	lBsPIS	:= .T.
	lBsCOF	:= .T.	
	PutGlbValue( cGrupoF010, ".F." )

	If (cAliasCL2)->CL2_REG == 'F100'

		IF lRgCmpCons

			aParF550	:= {}
			aAdd(aParF550, (cAliasCL2)->CL2_VLOPER)
			aAdd(aParF550, (cAliasCL2)->CL2_CSTPIS)
			aAdd(aParF550, 0)
			aAdd(aParF550, (cAliasCL2)->CL2_BCPIS)
			aAdd(aParF550, (cAliasCL2)->CL2_ALQPIS)
			aAdd(aParF550, (cAliasCL2)->CL2_VLPIS)
			aAdd(aParF550, (cAliasCL2)->CL2_CSTCOF )
			aAdd(aParF550, 0)
			aAdd(aParF550, (cAliasCL2)->CL2_BCPIS)
			aAdd(aParF550, (cAliasCL2)->CL2_ALQCOF)
			aAdd(aParF550, (cAliasCL2)->CL2_VLCOF)
			aAdd(aParF550, '99')
			aAdd(aParF550, '')
			aAdd(aParF550, cConta)
			aAdd(aParF550, '')

			PrcF550560(cGrupoF010, oBlocoF, aParF550)

			cRelacPai	:= oBlocoF:getGrupo()

			IF !Empty((cAliasCL2)->CL2_NUMPRO) .AND. !Empty((cAliasCL2)->CL2_INDPRO)

				If (cAliasCL2)->CL2_CSTPIS == '03'
					ProcRefC(cRelacPai, oBlocoF, 'F569', (cAliasCL2)->CL2_NUMPRO, (cAliasCL2)->CL2_INDPRO )
				Else
					ProcRefC(cRelacPai, oBlocoF, 'F559', (cAliasCL2)->CL2_NUMPRO, (cAliasCL2)->CL2_INDPRO )
				EndIF

				//Gera registro 1010 ou 1020 do processo referenciado
			    If	CCF->(MsSeek (xFilial ("CCF")+(cAliasCL2)->CL2_NUMPRO+(cAliasCL2)->CL2_INDPRO ))

					If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
						 Proc1010('1001000000001', oBloco1, 'CCF')
					ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
						Proc1020('1001000000001', oBloco1, 'CCF')
					EndIF

				EndIF
			EndIF

			aParF550	:= {}
			aAdd(aParF550, SM0->M0_CGC)
			aAdd(aParF550, '99')
			aAdd(aParF550, '')
			aAdd(aParF550, '00')
			aAdd(aParF550, (cAliasCL2)->CL2_VLOPER)
			aAdd(aParF550, '1')
			aAdd(aParF550, (cAliasCL2)->CL2_CSTPIS )
			aAdd(aParF550, (cAliasCL2)->CL2_CSTCOF )
			aAdd(aParF550, '' )
			aAdd(aParF550, (cAliasCL2)->CL2_DESCR)
			aAdd(aParF550, cConta)


			Proc1900('1001000000001', oBloco1, aParF550)

		Else

			//Tratamento para geração do registro 0150 do cadastro de participante
			IF lCl2Clifor .AND. lCl2Loja .AND. !Empty( (cAliasCL2)->CL2_CLIFOR ) .AND. !Empty( (cAliasCL2)->CL2_LOJA )
				//Trtamento do participante utilizando campos separados para código e loja
				cPart	:= (cAliasCL2)->CL2_CLIFOR
				cLoja	:= (cAliasCL2)->CL2_LOJA
			Else
				//Tratamento legado utilizando campo com código e loja concatenados
				cPart	:= SubStr((cAliasCL2)->CL2_PARTI,1,TAMSX3("A1_COD")[1])
				cLoja	:= SubStr((cAliasCL2)->CL2_PARTI,TAMSX3("A1_COD")[1]+1,TAMSX3("A1_LOJA")[1])
			EndIF

			cCod0150 := ''
			cCodProd:= ''

			IF lCL2Alias .AND. !Empty((cAliasCL2)->CL2_ALIAS)
				cAlsSA	:= (cAliasCL2)->CL2_ALIAS
			ElseIF (cAliasCL2)->CL2_PART	==	'1'
				cAlsSA   := "SA1"
			ElseIF (cAliasCL2)->CL2_PART	==	'2'
				cAlsSA   := "SA2"
			ElseIF (cAliasCL2)->CL2_INDOP	==	'0'
				cAlsSA   := "SA2"
			Else
				cAlsSA   := "SA1"
			EndIF
			IF !Empty(cPart)
				If (cAlsSA)->(MsSeek (xFilial(cAlsSA)+cPart+cLoja))
					cCod0150	:= FSA0080150(c0140, oTabela, oBloco0, cAlsSA, cAlsSA,lConcFil,dDataDe)
				EndIf
			EndIf

			//Tratamento para gerar registro 0200 para item

			If !Empty((cAliasCL2)->CL2_ITEM)
				If SB1->(MsSeek(xFilial("SB1")+(cAliasCL2)->CL2_ITEM))
					cCodProd	:= FSA0080200(c0140, oBloco0, , 'SB1', oTabela, lConcFil,nICMPAD,'','','', '',,dDataDe)
				EndIf
			EndIf

			//Para casos de CST 08 a base de calculo não deverá ser gerada.
			If (cAliasCL2)->CL2_CSTPIS $ '08|'
				lBsPIS := .F.
			EndIF
			If (cAliasCL2)->CL2_CSTCOF $ '08|'
				lBsCOF := .F.
			EndIF
			oBlocoF:setRelac(cGrupoF010)
			oBlocoF:setIndOper((cAliasCL2)->CL2_INDOP)
			oBlocoF:setCodPart(cCod0150)
			oBlocoF:setDtOper((cAliasCL2)->CL2_DTOPER)
			oBlocoF:setVlOper((cAliasCL2)->CL2_VLOPER)
			oBlocoF:setiCSTPis((cAliasCL2)->CL2_CSTPIS)
			oBlocoF:setIBasPis(Iif(lBsPIS,(cAliasCL2)->CL2_BCPIS,0))
			oBlocoF:setiAlqPis((cAliasCL2)->CL2_ALQPIS)
			oBlocoF:setIValPis((cAliasCL2)->CL2_VLPIS)
			oBlocoF:setiCSTCof((cAliasCL2)->CL2_CSTCOF)
			oBlocoF:setIBasCof(Iif(lBsCOF,(cAliasCL2)->CL2_BCCOF,0))
			oBlocoF:setiAlqCof((cAliasCL2)->CL2_ALQCOF)
			oBlocoF:setIValCof((cAliasCL2)->CL2_VLCOF)
			oBlocoF:setiCodBcc((cAliasCL2)->CL2_CODBCC)
			oBlocoF:setOriCrd((cAliasCL2)->CL2_INDCRD)
			oBlocoF:setConta(cConta)
			oBlocoF:setiCCusto(cCusto)
			oBlocoF:setDescri((cAliasCL2)->CL2_DESCR)
			oBlocoF:setCodItem(cCodProd) // ADICIONADO ITEM

			//Adiciona novo registro e grava na tabela temporária
			oTabela:GrvReg(oBlocoF:AddF100())


			IF !Empty((cAliasCL2)->CL2_NUMPRO) .AND. !Empty((cAliasCL2)->CL2_INDPRO)

				//Processa registro F111
				ProcRefC(oBlocoF:getGrupo(), oBlocoF, 'F111', (cAliasCL2)->CL2_NUMPRO, (cAliasCL2)->CL2_INDPRO )

				oTabela:GrvReg(oBlocoF:getF111())


				//Gera registro 1010 ou 1020 do processo referenciado
			    If	CCF->(MsSeek (xFilial ("CCF")+(cAliasCL2)->CL2_NUMPRO+(cAliasCL2)->CL2_INDPRO ))

					If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
						 Proc1010('1001000000001', oBloco1, 'CCF')
					ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
						Proc1020('1001000000001', oBloco1, 'CCF')
					EndIF

				EndIF
			EndIF

			oBlocoF:clsF100()
		EndIF

	//IRÁ GERAR REGISTRO F120 - CRÉDITO ATIVO FIXO - DEPRECIAÇÃO
	ElseIF (cAliasCL2)->CL2_REG == 'F120' .and.  mv_par08 <> 2

		oBlocoF:setRelac(cGrupoF010)
		oBlocoF:setiCodBcc((cAliasCL2)->CL2_CODBCC)
		oBlocoF:setIdeBem((cAliasCL2)->CL2_IDBEM)
		oBlocoF:setUtiBem((cAliasCL2)->CL2_IDUTI)
		oBlocoF:setDeprec((cAliasCL2)->CL2_VLOPER)
		oBlocoF:setVlExclu((cAliasCL2)->CL2_VLEXCL)
		oBlocoF:setiCSTPis((cAliasCL2)->CL2_CSTPIS)
		oBlocoF:setIBasPis((cAliasCL2)->CL2_BCPIS)
		oBlocoF:setiAlqPis((cAliasCL2)->CL2_ALQPIS)
		oBlocoF:setIValPis((cAliasCL2)->CL2_VLPIS)
		oBlocoF:setiCSTCof((cAliasCL2)->CL2_CSTCOF)
		oBlocoF:setIBasCof((cAliasCL2)->CL2_BCCOF)
		oBlocoF:setiAlqCof((cAliasCL2)->CL2_ALQCOF)
		oBlocoF:setIValCof((cAliasCL2)->CL2_VLCOF)
		oBlocoF:setOriCrd((cAliasCL2)->CL2_ORICRD)
		oBlocoF:setConta(cConta)
		oBlocoF:setiCCusto(cCusto)
		oBlocoF:setDescri((cAliasCL2)->CL2_DESCR)

		//Adiciona novo registro e grava na tabela temporária
		oTabela:GrvReg(oBlocoF:AddF120())


		IF !Empty((cAliasCL2)->CL2_NUMPRO) .AND. !Empty((cAliasCL2)->CL2_INDPRO)

			//Processa registro F129
			ProcRefC(oBlocoF:getGrupo(), oBlocoF, 'F129', (cAliasCL2)->CL2_NUMPRO, (cAliasCL2)->CL2_INDPRO )

			oTabela:GrvReg(oBlocoF:getF129())


			//Gera registro 1010 ou 1020 do processo referenciado
		    If	CCF->(MsSeek (xFilial ("CCF")+(cAliasCL2)->CL2_NUMPRO+(cAliasCL2)->CL2_INDPRO ))

				If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
					 Proc1010('1001000000001', oBloco1, 'CCF')
				ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
					Proc1020('1001000000001', oBloco1, 'CCF')
				EndIF

			EndIF
		EndIF

		oBlocoF:clsF120()


	//IRÁ GERAR REGISTRO F130 - CRÉDITO ATIVO FIXO - AQUISIÇÃO
	ElseIF (cAliasCL2)->CL2_REG == 'F130' .and.  mv_par08 <> 2

		oBlocoF:setRelac(cGrupoF010)
		oBlocoF:setiCodBcc((cAliasCL2)->CL2_CODBCC)
		oBlocoF:setIdeBem((cAliasCL2)->CL2_IDBEM)
		oBlocoF:setOriCrd((cAliasCL2)->CL2_ORICRD)
		oBlocoF:setUtiBem((cAliasCL2)->CL2_IDUTI)
		oBlocoF:setMesAqui((cAliasCL2)->CL2_MESANO)
		oBlocoF:setValAqui((cAliasCL2)->CL2_VLAQUI)
		oBlocoF:setVlExclu((cAliasCL2)->CL2_VLEXCL)
		oBlocoF:setDeprec((cAliasCL2)->CL2_VLPARC)
		oBlocoF:setIndParc((cAliasCL2)->CL2_INDPAC)
		oBlocoF:setiCSTPis((cAliasCL2)->CL2_CSTPIS)
		oBlocoF:setIBasPis((cAliasCL2)->CL2_BCPIS)
		oBlocoF:setiAlqPis((cAliasCL2)->CL2_ALQPIS)
		oBlocoF:setIValPis((cAliasCL2)->CL2_VLPIS)
		oBlocoF:setiCSTCof((cAliasCL2)->CL2_CSTCOF)
		oBlocoF:setIBasCof((cAliasCL2)->CL2_BCCOF)
		oBlocoF:setiAlqCof((cAliasCL2)->CL2_ALQCOF)
		oBlocoF:setIValCof((cAliasCL2)->CL2_VLCOF)
		oBlocoF:setConta(cConta)
		oBlocoF:setiCCusto(cCusto)
		oBlocoF:setDescri((cAliasCL2)->CL2_DESCR)

		//Adiciona novo registro e grava na tabela temporária
		If lF130Grp //Agrupa F130
			oBlocoF:AddF130(lF130Grp)
			lF130:= .T.
		Else
			oTabela:GrvReg(oBlocoF:AddF130())
		Endif


		IF !Empty((cAliasCL2)->CL2_NUMPRO) .AND. !Empty((cAliasCL2)->CL2_INDPRO)

			//Processa registro F130
			ProcRefC(oBlocoF:getGrupo(), oBlocoF, 'F139', (cAliasCL2)->CL2_NUMPRO, (cAliasCL2)->CL2_INDPRO )

			IF !lF130Grp
				oTabela:GrvReg(oBlocoF:getF139())
			Endif

			//Gera registro 1010 ou 1020 do processo referenciado
		    If	CCF->(MsSeek (xFilial ("CCF")+(cAliasCL2)->CL2_NUMPRO+(cAliasCL2)->CL2_INDPRO ))

				If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
					 Proc1010('1001000000001', oBloco1, 'CCF')
				ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
					Proc1020('1001000000001', oBloco1, 'CCF')
				EndIF

			EndIF
		EndIF

		IF !lF130Grp // Caso agrupe não limpa objeto
			oBlocoF:clsF130()
		Endif

	EndIF

	(cAliasCL2)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL2)
(cAliasCL2)->(DbCloseArea())

IF lF130 //Grava registro Agrupara e limpa Objeto
	oTabela:GrvReg(oBlocoF:getF130())
	oTabela:GrvReg(oBlocoF:getF139())
	oBlocoF:clsF130()
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCKY()
@description Função que irá fazer procesamento das informações do registro F600
			   gravado na tabela CKY.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoF010,String,Relação com registro pai F010.
@author Erick G. Dias
@since 06/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcCKY(dDataDe, dDataAte, cGrupoF010,oTabela,aNumeracao)

Local oBlocoF		:= EFDCBLOCOF():New()
Local cAliasCKY	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cRegime		:= ''

cCampos	:= '%CKY.CKY_INDRET	, CKY.CKY_DTRET	, CKY.CKY_CODREC	, CKY.CKY_CNPJ	, CKY.CKY_BASE,'
cCampos	+= 'CKY.CKY_TOTRET	, CKY.CKY_PISRET	, CKY.CKY_COFRET	, CKY.CKY_INDCON	, CKY.CKY_INDREC%'

cFiltro 	:= "%"
cFiltro 	+= "CKY.CKY_FILIAL= '"+ xFilial('CKY')+ "' AND "
cFiltro 	+= "CKY.CKY_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKY.CKY_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "%"

oBlocoF:setaNumer(aNumeracao)

cAliasCKY	:=	GetNextAlias()
BeginSql Alias cAliasCKY
	COLUMN CKY_DTRET AS DATE
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKY% CKY
	WHERE
	%Exp:cFiltro%
	CKY.%NotDel%

EndSql

DbSelectArea (cAliasCKY)
(cAliasCKY)->(DbGoTop ())


Do While !(cAliasCKY)->(Eof ())	
	PutGlbValue( cGrupoF010, ".F." )

	If (cAliasCKY)->CKY_INDREC == '1'
		cRegime	:= '0' //Não Cumulativo
	Else
		cRegime	:= '1'	//Cumulativo
	EndIF

	//IRÁ ADICIONAR REGISTRO F600.
	oBlocoF:setRelac(cGrupoF010)
	oBlocoF:setNatRet((cAliasCKY)->CKY_INDRET)
	oBlocoF:setDtRet((cAliasCKY)->CKY_DTRET)
	oBlocoF:setBasRet((cAliasCKY)->CKY_BASE)
	oBlocoF:setTotRet((cAliasCKY)->CKY_TOTRET)
	oBlocoF:setCodRec((cAliasCKY)->CKY_CODREC)
	oBlocoF:setRegime(cRegime)
	oBlocoF:setCnpj((cAliasCKY)->CKY_CNPJ)
	oBlocoF:setPisRet((cAliasCKY)->CKY_PISRET)
	oBlocoF:setCofRet((cAliasCKY)->CKY_COFRET)
	oBlocoF:setIndDec((cAliasCKY)->CKY_INDCON)
	oBlocoF:AddF600()

	(cAliasCKY)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKY)
(cAliasCKY)->(DbCloseArea())

//-------------------------------------------------------------------
//Grava registro F600 na tabela temporária
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoF:getF600())


FreeObj(oBlocoF)
oBlocoF:= nil

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCL1()
@description Função que irá fazer procesamento das informações do registro F500,
			   F510 gravado na tabela CL1, que são informações de regime de caixa.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoF010,String,Relação com registro pai F010.
@author Erick G. Dias
@since 06/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcCL1(dDataDe, dDataAte, cGrupoF010,oTabela,aNumeracao,oBloco0,lConcFil,oBloco1)
Local oBlocoF		:= EFDCBLOCOF():New()
Local cAliasCL1	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cConta		:= ''
Local lF07			:= AliasINdic('F07')
Local lCIE			:= AliasINdic('CIE')

cCampos	:= '%CL1.CL1_VLREC	, CL1.CL1_CSTPIS	, CL1.CL1_DSCPIS	, CL1.CL1_BSEPIS	, CL1.CL1_ALQPIS,'
cCampos	+= 'CL1.CL1_VLPIS		, CL1.CL1_CSTCOF	, CL1.CL1_BSECOF	, CL1.CL1_ALQCOF	, CL1.CL1_VLCOF,'
cCampos	+= 'CL1.CL1_MOD		, CL1.CL1_CFOP	, CL1.CL1_CODCTA,  CL1.CL1_PAUTA   ,CL1.CL1_ID%'

cFiltro 	:= "%"
cFiltro 	+= "CL1.CL1_FILIAL= '"+ xFilial('CL1')+ "' AND "
cFiltro 	+= "CL1.CL1_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CL1.CL1_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "%"

cAliasCL1	:=	GetNextAlias()
BeginSql Alias cAliasCL1

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL1% CL1
	WHERE
	%Exp:cFiltro%
	CL1.%NotDel%

EndSql

DbSelectArea (cAliasCL1)
(cAliasCL1)->(DbGoTop ())

oBlocoF:setaNumer(aNumeracao)

Do While !(cAliasCL1)->(Eof ())
	//IRÁ ADICIONAR REGISTRO F500 OU F510, CASO A OPERAÇÃO ESTIVER COM PAUTA DE PIS E COFINS.
	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasCL1)->CL1_CODCTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)	
	PutGlbValue( cGrupoF010, ".F." )


	oBlocoF:setRelac(cGrupoF010)
	oBlocoF:setRecAuf((cAliasCL1)->CL1_VLREC)
	oBlocoF:setiCSTPis((cAliasCL1)->CL1_CSTPIS)
	oBlocoF:setiVaDesc((cAliasCL1)->CL1_DSCPIS)
	oBlocoF:setIBasPis((cAliasCL1)->CL1_BSEPIS)
	oBlocoF:setiAlqPis((cAliasCL1)->CL1_ALQPIS)
	oBlocoF:setIValPis((cAliasCL1)->CL1_VLPIS)
	oBlocoF:setiCSTCof((cAliasCL1)->CL1_CSTCOF)
	oBlocoF:setIBasCof((cAliasCL1)->CL1_BSECOF)
	oBlocoF:setiAlqCof((cAliasCL1)->CL1_ALQCOF)
	oBlocoF:setIValCof((cAliasCL1)->CL1_VLCOF)
	oBlocoF:setnModelo((cAliasCL1)->CL1_MOD)
	oBlocoF:setiCFOP((cAliasCL1)->CL1_CFOP)
	oBlocoF:setConta(cConta)
	oBlocoF:setDescri('')

	If (cAliasCL1)->CL1_PAUTA == '0'
		//Se não for pauta irá gerar F500
		oBlocoF:AddF500()

	ElseIF (cAliasCL1)->CL1_PAUTA == '1'
		//Se for pauta então irá gerar F510
		oBlocoF:AddF510()

	EndIF

	If lF07

		ProcF07((cAliasCL1)->CL1_ID, dDataDe,Iif((cAliasCL1)->CL1_PAUTA == '1' ,.T.,.F.),oBlocoF:getGrupo(),oBlocoF,oBloco1, lCIE, cConta)

	EndIF

	(cAliasCL1)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL1)
(cAliasCL1)->(DbCloseArea())

//Gera informações do registro F500 na tabela temporária.
oTabela:GrvReg(oBlocoF:getF500())


//Gera informações do registro F510 na tabela temporária.
oTabela:GrvReg(oBlocoF:getF510())

If lF07
	//Gera informações do registro F509 na tabela temporária.
	oTabela:GrvReg(oBlocoF:getF509())

	//Gera informações do registro F519 na tabela temporária.
	oTabela:GrvReg(oBlocoF:getF519())

EndIF


FreeObj(oBlocoF)
oBlocoF:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCL7()
@description Função que irá fazer procesamento das informações do registro F525
			   gravado na tabela CL7, que são informações de regime de caixa.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoF010,String,Relação com registro pai F010.
@author Erick G. Dias
@since 06/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcCL7(dDataDe, dDataAte, cGrupoF010,oTabela,aNumeracao,oBloco0,lConcFil)

Local oBlocoF		:= EFDCBLOCOF():New()
Local cAliasCL7	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cConta		:= ''

cCampos	:= '%CL7.CL7_VLREC	, CL7.CL7_INDREC	, CL7.CL7_CNPJ	, CL7.CL7_NUMDOC	, CL7.CL7_CDITEM,'
cCampos	+= 'CL7.CL7_VLRECD	, CL7.CL7_CSTPIS	, CL7.CL7_CSTCOF	, CL7.CL7_INFCOM	, CL7.CL7_CODCTA%'

cFiltro 	:= "%"
cFiltro 	+= "CL7.CL7_FILIAL= '"+ xFilial('CL7')+ "' AND "
cFiltro 	+= "CL7.CL7_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CL7.CL7_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "%"

cAliasCL7	:=	GetNextAlias()
BeginSql Alias cAliasCL7

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL7% CL7
	WHERE
	%Exp:cFiltro%
	CL7.%NotDel%

EndSql

DbSelectArea (cAliasCL7)
(cAliasCL7)->(DbGoTop ())

oBlocoF:setaNumer(aNumeracao)

Do While !(cAliasCL7)->(Eof ())

	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasCL7)->CL7_CODCTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)	
	PutGlbValue( cGrupoF010, ".F." )

	oBlocoF:setRelac(cGrupoF010)
	oBlocoF:setValRecb((cAliasCL7)->CL7_VLREC)
	oBlocoF:setICmpRec((cAliasCL7)->CL7_INDREC)
	oBlocoF:setCnpj((cAliasCL7)->CL7_CNPJ)
	oBlocoF:setnNumNf((cAliasCL7)->CL7_NUMDOC)
	oBlocoF:setCodItem((cAliasCL7)->CL7_CDITEM)
	oBlocoF:setRecDet((cAliasCL7)->CL7_VLRECD)
	oBlocoF:setiCSTPis((cAliasCL7)->CL7_CSTPIS)
	oBlocoF:setiCSTCof((cAliasCL7)->CL7_CSTCOF)
	oBlocoF:setDescri((cAliasCL7)->CL7_INFCOM)
	oBlocoF:setConta(cConta)
	oBlocoF:AddF525()

	(cAliasCL7)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL7)
(cAliasCL7)->(DbCloseArea())

//Gera informações do registro F500 na tabela temporária.
oTabela:GrvReg(oBlocoF:getF525())


FreeObj(oBlocoF)
oBlocoF:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcP100()
@description Função que irá buscar as informações para geração do bloco P
			   Estas informações já foram processadas pela apuração, aqui
			   somente serão lidar e formatadas nos devidos registros.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoP010,String,Relação com registro pai P010.
@param	oTabela,Objeto,Objeto da classe ARRAYTOTMP
@param aNumeracao,Array,Array com numeração dos registros gerados
@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcP100(dDataDe, dDataAte, cGrupoP010,oTabela,aNumeracao,oBloco0,lConcFil,lCount,oBlocoP)

Local cAliasCKX		:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local nQtde			:= 0
Local lCNO			:= .F.
Local cAliasF3Z		:= ''
Local cGrupoP100	:= ''
Local lEXT			:= IsInCallStack('EXTFISXTAF')

lCNO := AliasIndic("F3Z")

If lCNO
	cAliasF3Z	:= GetNextAlias()
EndIf

IF lCount
	cCampos := '% COUNT(*) CKXCOUNT %'
Else
	cCampos	:= '%CKX.CKX_VLBRUT	, CKX.CKX_CODATI	, CKX.CKX_VLATI	, CKX.CKX_EXCLU	, CKX.CKX_BASE,'
	cCampos	+= 'CKX.CKX_ALIQ		, CKX.CKX_VLCPRB	, CKX.CKX_CONTA	, CKX.CKX_INFORM%'
EndIF

cFiltro 	:= "%"
cFiltro 	+= "CKX.CKX_FILIAL= '"+ xFilial('CKX')+ "' AND "
cFiltro 	+= "CKX.CKX_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKX.CKX_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKX.CKX_SALDO <> '1' AND "
cFiltro 	+= "%"

cAliasCKX	:=	GetNextAlias()
BeginSql Alias cAliasCKX

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKX% CKX
	WHERE
	%Exp:cFiltro%
	CKX.%NotDel%

EndSql

DbSelectArea (cAliasCKX)
(cAliasCKX)->(DbGoTop ())

//Somente verifica a quantidade de registros que serão processados
IF lCount
	Do While !(cAliasCKX)->(Eof ())

		nQtde	:= (cAliasCKX)->CKXCOUNT

		(cAliasCKX)->(DbSkip ())
	EndDo

Else
	//irá processar de fato os registros P100
	oBlocoP:setaNumer(aNumeracao)

	//Agrupa relação P010
	If !(cAliasCKX)->(Eof ())
		oBlocoP:AddaRegRec(cGrupoP010,(cAliasCKX)->CKX_VLBRUT)
	Endif

	Do While !(cAliasCKX)->(Eof ())

		cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasCKX)->CKX_CONTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)

		//passa informações para classe gerar registro P100
		oBlocoP:setRelac(cGrupoP010)
		oBlocoP:setDtIni(dDataDe)
		oBlocoP:setDtFinal(dDataAte)
		oBlocoP:setRecBrut((cAliasCKX)->CKX_VLBRUT)
		oBlocoP:setCodAtv((cAliasCKX)->CKX_CODATI)
		oBlocoP:setVlAtv((cAliasCKX)->CKX_VLATI)
		oBlocoP:setVlExc((cAliasCKX)->CKX_EXCLU)
		oBlocoP:setBasCPRB((cAliasCKX)->CKX_BASE)
		oBlocoP:setAlq((cAliasCKX)->CKX_ALIQ)
		oBlocoP:setVlCPRB((cAliasCKX)->CKX_VLCPRB)
		oBlocoP:setContCtb(cConta)
		oBlocoP:setInfComp((cAliasCKX)->CKX_INFORM)
		oBlocoP:AddP100()

		cGrupoP100 := oBlocoP:getGrupo()

		If lCNO .AND. lEXT
			QryT082AD(cAliasF3Z,(cAliasCKX)->CKX_CODATI, dDataDe, dDataAte, cGrupoP100, oBlocoP,oBloco0,oTabela,lConcFil, (cAliasCKX)->CKX_CONTA)
		EndIf

		(cAliasCKX)->(DbSkip ())
	EndDo
	//Apenas para arquivo do Extrator, pois informação servirá apenas para o REINF
	If lEXT
		//Gerar aqui os registros P199, que tratam do detalhe das reduções do registro P100.
		ProcP199(dDataDe, dDataAte, oBlocoP, oTabela)
	EndIf

EndIF

DbSelectArea (cAliasCKX)
(cAliasCKX)->(DbCloseArea())

Return nQtde

//-------------------------------------------------------------------
/*/{Protheus.doc} QryT082AD()
@description Query para identificar os registros T082AD filhos do
T082.
@author Matheus Prada
@since 09/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function QryT082AD(cAliasF3Z,cCodAti, dDataDe, dDataAte, cGrupoP100, oBlocoP,oBloco0,oTabela,lConcFil, cConta)

Local cCampos	:= ''
Local cFiltro	:= ''
Local lCNO		:= .T.

Default cCodAti := ''
Default cConta  := '' 

cCampos	:= '%F3Z.F3Z_VLBRUT, F3Z.F3Z_CODATI, F3Z.F3Z_VLATI, F3Z.F3Z_EXCLU, F3Z.F3Z_BASE'
cCampos	+= ', F3Z.F3Z_ALIQ, F3Z.F3Z_VLCPRB, F3Z.F3Z_CONTA, F3Z.F3Z_CNO%'

cFiltro 	:= "%"
cFiltro 	+= "F3Z.F3Z_FILIAL= '"+ xFilial('F3Z')+ "' AND "
cFiltro 	+= "F3Z.F3Z_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "F3Z.F3Z_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "F3Z.F3Z_SALDO <> '1' AND "
cFiltro 	+= "F3Z.F3Z_CODATI = '" + %Exp:cCodAti% + "' AND "
cFiltro		+= "F3Z.F3Z_CONTA = '" + %Exp:cConta% + "' AND " 
cFiltro 	+= "%"

BeginSql Alias cAliasF3Z

	SELECT
	%Exp:cCampos%

	FROM
	%Table:F3Z% F3Z
	WHERE
	%Exp:cFiltro%
	F3Z.%NotDel%

EndSql

DbSelectArea (cAliasF3Z)
(cAliasF3Z)->(DbGoTop ())

Do While !(cAliasF3Z)->(Eof ())

	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasF3Z)->F3Z_CONTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)

	//passa informações para classe gerar registro P199_2
	oBlocoP:setRelac(cGrupoP100)
	oBlocoP:setDtIni(dDataDe)
	oBlocoP:setDtFinal(dDataAte)
	oBlocoP:setRecBrut((cAliasF3Z)->F3Z_VLBRUT)
	oBlocoP:setCodAtv((cAliasF3Z)->F3Z_CODATI)
	oBlocoP:setVlAtv((cAliasF3Z)->F3Z_VLATI)
	oBlocoP:setVlExc((cAliasF3Z)->F3Z_EXCLU)
	oBlocoP:setBasCPRB((cAliasF3Z)->F3Z_BASE)
	oBlocoP:setAlq((cAliasF3Z)->F3Z_ALIQ)
	oBlocoP:setVlCPRB((cAliasF3Z)->F3Z_VLCPRB)
	oBlocoP:setContCtb(cConta)
	oBlocoP:setValCNO((cAliasF3Z)->F3Z_CNO)
	oBlocoP:AddP100(lCNO)

	(cAliasF3Z)->(DbSkip ())
EndDo

DbSelectArea (cAliasF3Z)
(cAliasF3Z)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcP199()
@description Função que irá buscar as informações para geração do bloco P199
			   Registrando as informações referêntes ao detalhe das exclusões
			   de receita no período.

@param	dDataDe,Date,Dia inicial da geração do arquivo.
@param	dDataAte,Date,Dia final da geração do arquivo.
@author Vogas Júnior
@since 20/09/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function ProcP199(dDataDe, dDataAte, oBlocoP,oTabela)

Local cAliasF2S	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''
Local nQtde		:= 0
Local nPos		:= 0

If AliasIndic('F2S')

	cCampos	:= '%F2S.F2S_TPAJUS, F2S.F2S_CODAJU	, F2S.F2S_VLRAJU, F2S.F2S_DESCRI, F2S.F2S_PER%'

	cFiltro	:= "%"
	cFiltro	+= "F2S.F2S_FILIAL= '"+ xFilial('F2S')+ "' AND "
	cFiltro	+= "F2S.F2S_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
	cFiltro	+= "F2S.F2S_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
	cFiltro	+= "F2S.F2S_TRIBUT = '2' AND "
	cFiltro	+= "F2S.F2S_TPAJUS = '0' AND "
	cFiltro	+= "%"

	cAliasF2S :=	GetNextAlias()
	BeginSql Alias cAliasF2S

		SELECT
		%Exp:cCampos%

		FROM
		%Table:F2S% F2S
		WHERE
		%Exp:cFiltro%
		F2S.%NotDel%

	EndSql

	DbSelectArea (cAliasF2S)
	(cAliasF2S)->(DbGoTop ())

	Do While !(cAliasF2S)->(Eof ())

		oBlocoP:setIndAju((cAliasF2S)->F2S_TPAJUS)
		oBlocoP:setCodAju((cAliasF2S)->F2S_CODAJU)
		oBlocoP:setValAju((cAliasF2S)->F2S_VLRAJU)
		oBlocoP:setDescAju((cAliasF2S)->F2S_DESCRI)
		oBlocoP:setDtRef((cAliasF2S)->F2S_PER)
		oBlocoP:AddP199()

		(cAliasF2S)->(DbSkip ())
	EndDo

	DbSelectArea (cAliasF2S)
	(cAliasF2S)->(DbCloseArea())

	//Grava P199 na tabela temporária
	oTabela:GrvReg(oBlocoP:getP199())
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcP200()
@description Função que irá processar registro P200 e P210. Este registro
			   deverá ser gerado a nível de emporesa.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoP010,String,Relação com registro pai P001
@param	oTabela,Objeto,Objeto da classe ARRAYTOTMP
@param aNumeracao,Array,Array com numeração dos registros gerados

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcP200(dDataDe, dDataAte, cGrupoP001,oTabela,aNumeracao,oBloco0,c0140,oBlocoP)

Local cMesAno		:= Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe)))
Local apar0145	:= {}
Local lConsol   := FS007ApCon(dDataDe) 			//Se houver ao menos uma linha de apuração consolidada, então a rotina irá considerar somente informações da apuração consolidada.

//ABAIXO QUERY PARA GERAR REGISTRO P200
cCampos	:= '%CKV.CKV_TOTAP	, CKV.CKV_AJRD	, CKV.CKV_AJAC	, CKV.CKV_VLREC	, CKV.CKV_COD, CKV.CKV_RECBRU, CKV.CKV_RECATI%'

cFiltro 	:= "%"
cFiltro 	+= "CKV.CKV_FILIAL= '"+ xFilial('CKV')+ "' AND "
cFiltro 	+= "CKV.CKV_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKV.CKV_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKV.CKV_CONSOL = " + ValToSQL(Iif(lConsol,'1','2')) + " AND "
cFiltro 	+= "%"

cAliasCKV	:=	GetNextAlias()
BeginSql Alias cAliasCKV

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKV% CKV
	WHERE
	%Exp:cFiltro%
	CKV.%NotDel%

EndSql

DbSelectArea (cAliasCKV)
(cAliasCKV)->(DbGoTop ())

oBlocoP:setaNumer(aNumeracao)

Do While !(cAliasCKV)->(Eof ())
	//passa informações para classe gerar registro P200
	oBlocoP:setRelac(cGrupoP001)
	oBlocoP:setPerRef(cMesAno)
	oBlocoP:setTotApu((cAliasCKV)->CKV_TOTAP)
	oBlocoP:setAjuRed((cAliasCKV)->CKV_AJRD)
	oBlocoP:setAjuAcr((cAliasCKV)->CKV_AJAC)
	oBlocoP:setTotCPRB((cAliasCKV)->CKV_VLREC)
	oBlocoP:setCodRec((cAliasCKV)->CKV_COD)
	oBlocoP:AddP200()

	//Gerar aqui os registros P210, que tratam dos ajustes no registro P200.
	ProcP210(dDataDe, dDataAte, oBlocoP:getGrupo(),(cAliasCKV)->CKV_COD,oBlocoP)

	aAdd(apar0145,cvaltoChar(mv_par21))
	aAdd(apar0145,(cAliasCKV)->CKV_RECBRU)
	aAdd(apar0145,(cAliasCKV)->CKV_RECATI)
	aAdd(apar0145,(cAliasCKV)->CKV_RECBRU - (cAliasCKV)->CKV_RECATI)
	aAdd(apar0145,'')

	Proc0145(c0140,oBloco0,apar0145)

	(cAliasCKV)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKV)
(cAliasCKV)->(DbCloseArea())

//Grava registro P200 na tabela temporária
oTabela:GrvReg(oBlocoP:getP200())

//Grava P210 na tabela temporária
oTabela:GrvReg(oBlocoP:getP210())

//Grava registro P200 na tabela temporária
oTabela:GrvReg(oBloco0:get0145())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcP210()
@description Esta Função irá buscar informações do registro P210 na tabela CKW,
			   aqui serão gerados os registros filhos o registro P20
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoP200,String,Relação com registro pai P200.
@param cCodAtiv,String,Código de atividade gerado no registro P200 pai.
@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcP210(dDataDe, dDataAte, cGrupoP200,cCodAtiv,oBlocoP)

Local cAliasCKW	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CKW.CKW_TPAJU	, CKW.CKW_VLAJU	, CKW.CKW_CODAJU	, CKW.CKW_NUM	, CKW.CKW_DESCR,'
cCampos	+= 'CKW.CKW_DTREF%'

cFiltro 	:= "%"
cFiltro 	+= "CKW.CKW_FILIAL= '"+ xFilial('CKW')+ "' AND "
cFiltro 	+= "CKW.CKW_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKW.CKW_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKW.CKW_CODREC = '" + %Exp:cCodAtiv% +"' AND "
cFiltro 	+= "%"

cAliasCKW	:=	GetNextAlias()
BeginSql Alias cAliasCKW

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKW% CKW
	WHERE
	%Exp:cFiltro%
	CKW.%NotDel%

EndSql

DbSelectArea (cAliasCKW)
(cAliasCKW)->(DbGoTop ())
TcSetField(cAliasCKW,"CKW_DTREF","D",8,0)

Do While !(cAliasCKW)->(Eof ())
	//passa informações para classe gerar registro P210
	oBlocoP:setRelac(cGrupoP200)
	oBlocoP:setIndAju((cAliasCKW)->CKW_TPAJU)
	oBlocoP:setValAju((cAliasCKW)->CKW_VLAJU)
	oBlocoP:setCodAju((cAliasCKW)->CKW_CODAJU)
	oBlocoP:setNumDoc((cAliasCKW)->CKW_NUM)
	oBlocoP:setDescAju((cAliasCKW)->CKW_DESCR)
	oBlocoP:setDtRef((cAliasCKW)->CKW_DTREF)
	oBlocoP:AddP210()

	(cAliasCKW)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKW)
(cAliasCKW)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcBlcI()
@description Esta função irá gerar os registros do bloco I. Irá buscar
			   informações da tabela CL5 para geração de I100
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoI010,String,Relação com registro pai I010.
@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcBlcI(dDataDe, dDataAte, cGrupoI010,oTabela,aNumeracao,oBloco0,oTabela,lConcFil,oBloco1)

Local oBlocoI		:= EFDCBLOCOI():New()
Local cAliasCL5	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cGrupoI100	:= ''

cCampos	:= '%CL5.CL5_VLFAT	, CL5.CL5_CST			, CL5.CL5_DEDG	, CL5.CL5_DEDESP	, CL5.CL5_BASPIS,'
cCampos	+= 'CL5.CL5_ALQPIS	, CL5.CL5_VALPIS		,CL5.CL5_BASCOF	, CL5.CL5_ALQCOF	, CL5.CL5_VALCOF,'
cCampos	+= 'CL5.CL5_INFCOM	, CL5.CL5_NUMPRO     ,CL5_INDPRO%'

cFiltro 	:= "%"
cFiltro 	+= "CL5.CL5_FILIAL= '"+ xFilial('CL5')+ "' AND "
cFiltro 	+= "CL5.CL5_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CL5.CL5_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "%"

cAliasCL5	:=	GetNextAlias()
BeginSql Alias cAliasCL5

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL5% CL5
	WHERE
	%Exp:cFiltro%
	CL5.%NotDel%

EndSql

DbSelectArea (cAliasCL5)
(cAliasCL5)->(DbGoTop ())

oBlocoI:setaNumer(aNumeracao)

Do While !(cAliasCL5)->(Eof ())
	//passa informações para classe gerar registro I100
	oBlocoI:setRelac(cGrupoI010)
	oBlocoI:setVlRec((cAliasCL5)->CL5_VLFAT)
	oBlocoI:setCst((cAliasCL5)->CL5_CST)
	oBlocoI:setExGer((cAliasCL5)->CL5_DEDG)
	oBlocoI:setExEsp((cAliasCL5)->CL5_DEDESP)
	oBlocoI:setBasPis((cAliasCL5)->CL5_BASPIS)
	oBlocoI:setAlqPis((cAliasCL5)->CL5_ALQPIS)
	oBlocoI:setValPis((cAliasCL5)->CL5_VALPIS)
	oBlocoI:setBasCof((cAliasCL5)->CL5_BASCOF)
	oBlocoI:setAlqCof((cAliasCL5)->CL5_ALQCOF)
	oBlocoI:setValCof((cAliasCL5)->CL5_VALCOF)
	oBlocoI:setInfComp((cAliasCL5)->CL5_INFCOM)
	oBlocoI:AddI100()

	If !Empty((cAliasCL5)->CL5_NUMPRO)
		ProcRefC(oBlocoI:getGrupo(), oBlocoI, 'I199', (cAliasCL5)->CL5_NUMPRO, (cAliasCL5)->CL5_INDPRO )
	EndIF

	//AQUI FAZ CHAMADA PARA GERAÇÃO DOS REGISTROS FILHOS I200
	ProcI2300(dDataDe, ;
				dDataAte,;
				oBlocoI:getGrupo(),;
				(cAliasCL5)->CL5_CST,;
				(cAliasCL5)->CL5_ALQPIS,;
				(cAliasCL5)->CL5_ALQCOF,;
				'I200',;
				(cAliasCL5)->CL5_NUMPRO,;
				(cAliasCL5)->CL5_INDPRO,;
				oBloco0,;
				oTabela,;
				lConcFil,;
				oBlocoI,;
				'',;
				oBloco1)



	(cAliasCL5)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL5)
(cAliasCL5)->(DbCloseArea())


//-------------------------------------------------------------------
//Gera informações do registro I100 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI100())


//-------------------------------------------------------------------
//Gera informações do registro I199 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI199())


//-------------------------------------------------------------------
//Gera informações do registro I200 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI200())


//-------------------------------------------------------------------
//Gera informações do registro I299 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI299())


//-------------------------------------------------------------------
//Gera informações do registro I300 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI300())


//-------------------------------------------------------------------
//Gera informações do registro I399 na tabela temporária.
//-------------------------------------------------------------------
oTabela:GrvReg(oBlocoI:getI399())


oBlocoI:clsI100()

FreeObj(oBlocoI)
oBlocoI:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcI200()
@description Esta função irá gerar os registros do bloco I. Irá, gerar registro
				I200 ou I300, que serão filhos do registro I100 ou I200, considerando combinação
				de CST, alíquota de PIS e alíquota de COFINS. Estas informações
				estão gravadas na tabela CL6.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoIX00,String,Relação com registro pai I100 OU I200.
@param cCst,String,CST utilizado no registro pai I100.
@param nAlqPis,Integer,Alíquota de PIS utilizado no registro pai I100
@param nAlqCof,Integer,Alíquota de Cofins utilizado no registro pai I100
@param cReg,String,Registro que deverá ser processado, I200 ou I300

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function ProcI2300(dDataDe, dDataAte, cGrupoIX00, cCst, nAlqPis, nAlqCof, cReg, cNumPro, cIndPro,oBloco0,oTabela,lConcFil,oBlocoI,cCodI300,oBloco1,cI300Cpo,cI300Cta)

Local cAliasCL6	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cGrupoI200	:= ''
Local cGrupoI300	:= ''
Local cConta		:= ''

Default cCodI300	:= ''
Default cI300Cpo	:= ''
Default cI300Cta	:= ''

cCampos	:= '%CL6.CL6_NUMCPO	, CL6.CL6_CODIGO	, CL6.CL6_VALOR	, CL6.CL6_CONTA	, CL6.CL6_INFCOM%'

cFiltro 	:= "%"
cFiltro 	+= "CL6.CL6_FILIAL = " + ValToSql(xFilial('CL6')) + " AND "
cFiltro 	+= "CL6.CL6_PER   >= " + ValToSql(dDataDe)        + " AND "
cFiltro 	+= "CL6.CL6_PER   <= " + ValToSql(dDataAte)       + " AND "
cFiltro 	+= "CL6.CL6_REG    = " + ValToSql(cReg)           + " AND "
cFiltro 	+= "CL6.CL6_CST    = " + ValToSql(cCst)           + " AND "
cFiltro 	+= "CL6.CL6_ALQPIS = " + ValToSql(nAlqPis)        + " AND "
cFiltro 	+= "CL6.CL6_ALQCOF = " + ValToSql(nAlqCof)        + " AND "
cFiltro 	+= "CL6.CL6_VALOR  > " + ValToSql(0)   			  + " AND "

IF !Empty(cCodI300)
	cFiltro 	+= "SUBSTRING(CL6.CL6_CODIGO,1,5) = " + ValToSql(Alltrim(cCodI300)) + " AND "
	cFiltro 	+= "CL6_NUMCPO = " + ValToSql(cI300Cpo) + " AND CL6_CONTA = " + ValToSql(cI300Cta) + " AND "
EndIF

cFiltro 	+= "%"

cAliasCL6	:=	GetNextAlias()
BeginSql Alias cAliasCL6

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL6% CL6
	WHERE
	%Exp:cFiltro%
	CL6.%NotDel%

EndSql

DbSelectArea (cAliasCL6)
(cAliasCL6)->(DbGoTop ())

Do While !(cAliasCL6)->(Eof ())

	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr((cAliasCL6)->CL6_CONTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)

	If cReg == 'I200'
		//AQUI IRÁ PASSAR INFORMAÇÕES PARA GERAÇÃO DO REGISTRO I200
		oBlocoI:setRelac(cGrupoIX00)
		oBlocoI:setNumCpo((cAliasCL6)->CL6_NUMCPO)
		oBlocoI:setCod7112((cAliasCL6)->CL6_CODIGO)
		oBlocoI:setVlComp((cAliasCL6)->CL6_VALOR)
		oBlocoI:setCodCta(cConta)
		oBlocoI:setInfComp((cAliasCL6)->CL6_INFCOM)
		cGrupoI200	:= oBlocoI:AddI200()
		//AQUI FAZ CHAMADA PARA GERAÇÃO DOS REGISTROS FILHOS I200
		ProcI2300(dDataDe, ;
				dDataAte,;
				oBlocoI:getGrupo(),;
				cCst,;
				nAlqPis, ;
				nAlqCof,;
				'I300',;
				cNumPro,;
				cIndPro,;
				oBloco0,;
				oTabela,;
				lConcFil,;
				oBlocoI,;
				(cAliasCL6)->CL6_CODIGO,;
				oBloco1,;
				' ',;
				(cAliasCL6)->CL6_CONTA)

		If !Empty(cNumPro)
			ProcRefC(cGrupoI200, oBlocoI, 'I299', cNumPro, cIndPro )

			//Gera registro 1010 ou 1020 do processo referenciado
		    If	CCF->(MsSeek (xFilial ("CCF")+cNumPro+cIndPro ))

				If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
					 Proc1010('1001000000001', oBloco1, 'CCF')
				ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
					Proc1020('1001000000001', oBloco1, 'CCF')
				EndIF

			EndIF

		EndIF


	ElseIf cReg == 'I300'
		//AQUI IRÁ PASSAR INFORMAÇÕES PARA GERAÇÃO DO REGISTRO I300
		oBlocoI:setRelac(cGrupoIX00)
		oBlocoI:setCod7134((cAliasCL6)->CL6_CODIGO)
		oBlocoI:setVlDet((cAliasCL6)->CL6_VALOR)
		oBlocoI:setCodCta(cConta)
		oBlocoI:setInfComp((cAliasCL6)->CL6_INFCOM)
		cGrupoI300	:= oBlocoI:AddI300()

		If !Empty(cNumPro)
			ProcRefC(cGrupoI300, oBlocoI, 'I399', cNumPro, cIndPro )

		EndIF

	EndIF
	(cAliasCL6)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL6)
(cAliasCL6)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0111()
@description Esta função irá gerar o registro 0111, onde as informações estão
			   gravadas na tabela CKU.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupo0110,String,Relação com registro pai 0110.

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Function Proc0111(dDataDe, dDataAte, cGrupo0110,oTabela,oBloco0,mv_par08)

Local cAliasCKU	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local nSomaTot	:= 0
Local lConsol   := FS007ApCon(dDataDe) 			//Se houver ao menos uma linha de apuração consolidada, então a rotina irá considerar somente informações da apuração consolidada.

cCampos	:= '%SUM(CKU.CKU_RTNC) AS CKU_RTNC , SUM(CKU.CKU_RNTNC) AS 	CKU_RNTNC,'
ccampos    += 'SUM(CKU.CKU_EXP) AS CKU_EXP ,SUM( CKU.CKU_RTC) AS CKU_RTC%'

cFiltro 	:= "%"
cFiltro 	+= "CKU.CKU_FILIAL= '"+ xFilial('CKU')+ "' AND "
cFiltro 	+= "CKU.CKU_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKU.CKU_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKU.CKU_CONSOL = " + ValToSQL(Iif(lConsol,'1','2')) + " AND "
cFiltro 	+= "%"

cAliasCKU	:=	GetNextAlias()
BeginSql Alias cAliasCKU

	SELECT
	%Exp:cCampos%
	FROM
	%Table:CKU% CKU
	WHERE
	%Exp:cFiltro%
	CKU.%NotDel%

EndSql
DbSelectArea (cAliasCKU)
(cAliasCKU)->(DbGoTop ())

Do While !(cAliasCKU)->(Eof ())
	//passa informações para classe gerar registro 0111
	//PAREI AQUI, FAZER SETERS DA CLASSE DO BOCO 0
	nSomaTot	:= (cAliasCKU)->CKU_RTNC + (cAliasCKU)->CKU_RNTNC + (cAliasCKU)->CKU_EXP + iif(mv_par08 <> 1,(cAliasCKU)->CKU_RTC,0)
	oBloco0:setRelac(cGrupo0110)
	oBloco0:setRecMI((cAliasCKU)->CKU_RTNC)
	oBloco0:setRecNT((cAliasCKU)->CKU_RNTNC)
	oBloco0:setRecEx((cAliasCKU)->CKU_EXP)
	If mv_par08 <> 1
	  oBloco0:setRecCum((cAliasCKU)->CKU_RTC)
	EndIf
	oBloco0:setRecTot(nSomaTot)

	oTabela:GrvReg(oBloco0:Add0111())


	(cAliasCKU)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKU)
(cAliasCKU)->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0900()
@description Função que buscará informações da CIC para gerar registro 0900

@author Erick G. Dias
@since 09/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function Proc0900(dDataDe, dDataAte, oTabela, oBloco0, lConsolF )

Local cAliasCIC		:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local lGrava		:= .F.
Local lConsol	    := FS007ApCon(dDataDe)
Local cBloco 		:= ""

cCampos	:= '%CIC.CIC_BLOCO, CIC.CIC_REC, CIC.CIC_RECNB%'

cFiltro 	:= "%"
cFiltro 	+= "CIC.CIC_FILIAL=  " + ValToSQL(xFilial('CIC'))       + " AND "
cFiltro 	+= "CIC.CIC_PER>=    " + ValToSQL(dDataDe)              + " AND "
cFiltro 	+= "CIC.CIC_PER<=    " + ValToSQL(dDataAte)             + " AND "
cFiltro 	+= "CIC.CIC_CONSOL = " + ValToSQL(Iif(lConsol,'1','2')) + " AND "
cFiltro 	+= "%"

cAliasCIC	:=	GetNextAlias()
BeginSql Alias cAliasCIC

	SELECT
	%Exp:cCampos%
	FROM
	%Table:CIC% CIC
	WHERE
	%Exp:cFiltro%
	CIC.%NotDel%

EndSql
DbSelectArea (cAliasCIC)
(cAliasCIC)->(DbGoTop ())

lGrava := !(cAliasCIC)->(Eof ())

Do While !(cAliasCIC)->(Eof ())

	cBloco	:= Alltrim((cAliasCIC)->CIC_BLOCO)

	IF lConsolF
		//Se for regime cumulativo consolidado ou caixa, toda receita será demonstrada no bloco F
		oBloco0:setRecF((cAliasCIC)->CIC_REC)
		oBloco0:setNRBF((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "A"
		oBloco0:setRecA((cAliasCIC)->CIC_REC)
		oBloco0:setNRBA((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "C"
		oBloco0:setRecC((cAliasCIC)->CIC_REC)
		oBloco0:setNRBC((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "D"
		oBloco0:setRecD((cAliasCIC)->CIC_REC)
		oBloco0:setNRBD((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "F"
		oBloco0:setRecF((cAliasCIC)->CIC_REC)
		oBloco0:setNRBF((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "I"
		oBloco0:setRecI((cAliasCIC)->CIC_REC)
		oBloco0:setNRBI((cAliasCIC)->CIC_RECNB)

	ElseIf cBloco == "1"
		oBloco0:setRec1((cAliasCIC)->CIC_REC)
		oBloco0:setNRB1((cAliasCIC)->CIC_RECNB)

	EndIF

	(cAliasCIC)->(DbSkip ())
EndDo
DbSelectArea (cAliasCIC)
(cAliasCIC)->(DbCloseArea())

//Gravação do registro 0900
If lGrava
	//Adiciona registro 0900
	oBloco0:setRelac('')
	oBloco0:Add0900()
	//Grava informação do registro 0900
	oTabela:GrvReg(oBloco0:get0900())
EndIf

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM100500()
@description Esta função irá processar as informações e valores dos registros
			   M100 e M500, gravados nas tabelas CKZ E CL8
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupo0110,String,Relação com registro pai M010.

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Function PrcM100500(dDataDe, dDataAte, cGrupoM010,oTabela,aNumeracao,oBloco0,oTabela,lConcFil,lConsol,lDetAju)

Local oM100M500		:= EFDCBLOCOM():New()
Local cAliasCL8	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cJoin		:= ''
Local lPauta		:= .F.
Local cIndic		:= ''
Local cGrupomX00	:= ''
Local cOrderBy	:=	''
Local cGroupBy	:= ''
Local cChv100500	:= ''
Local cChave	:= ""

cCampos	:= '%CKZ.CKZ_TRIB		, CKZ.CKZ_ALIQ	, CKZ.CKZ_COD	, CL8.CL8_INDCRE	, '
cCampos	+= 'SUM(CL8.CL8_BSCALC) as CL8_BSCALC, SUM(CL8.CL8_VLCRED) as CL8_VLCRED	, SUM(CL8.CL8_AJAC) as CL8_AJAC	,SUM(CL8.CL8_AJRD) as CL8_AJRD, '
cCampos	+= 'SUM(CL8.CL8_DIF) as CL8_DIF	, Sum(CL8.CL8_TOTCRD) as CL8_TOTCRD,SUM(CL8.CL8_CRDUTI) as CL8_CRDUTI	, CL8.CL8_CHV		, CL8.CL8_CODBCC%'
//JOIN COM TABELA CL8 - CRÉDITOS CONSOLIDADOS
cJoin	:=	"LEFT JOIN "+RetSqlName("CL8")+" CL8 ON(CL8.CL8_FILIAL='"+xFilial("CL8")+"' AND CL8.CL8_CHV=CKZ.CKZ_ID AND CL8.D_E_L_E_T_=' ') "
cJoin	:= '%' + cJoin + '%'


cGroupBy:= '%GROUP BY CL8.CL8_CHV, CL8.CL8_CODBCC,CKZ.CKZ_COD,CKZ.CKZ_TRIB,CKZ.CKZ_ALIQ, CL8.CL8_INDCRE ORDER BY CKZ.CKZ_TRIB, CL8.CL8_CHV	%'

cFiltro 	:= "%"
cFiltro 	+= "CKZ.CKZ_FILIAL= '"+ xFilial('CKZ')+ "' AND "
cFiltro 	+= "CKZ.CKZ_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKZ.CKZ_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKZ.CKZ_REGIME= '1' AND "	//Somente operaçõe do regime não cumulativo
cFiltro 	+= "CKZ.CKZ_DEBCRD= '2' AND " //Somente operações com direito ao crédito

IF lConsol
	cFiltro 	+= "CL8.CL8_CONSOL ='1' AND " //Somente operações com direito ao crédito
	cFiltro 	+= "CKZ.CKZ_CONSOL ='1' AND " //Somente operações com direito ao crédito
Else
	cFiltro 	+= "CL8.CL8_CONSOL ='2' AND " //Somente operações com direito ao crédito
	cFiltro 	+= "CKZ.CKZ_CONSOL ='2' AND " //Somente operações com direito ao crédito
EndIF

cFiltro 	+= "%"

cAliasCL8	:=	GetNextAlias()
BeginSql Alias cAliasCL8

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKZ% CKZ
	%Exp:cJoin%
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%
	%Exp:cGroupBy%


EndSql

DbSelectArea (cAliasCL8)
(cAliasCL8)->(DbGoTop ())
oM100M500:setaNumer(aNumeracao)
Do While !(cAliasCL8)->(Eof ())

	//VERIFICAÇÃO PARA DECIDIR SE PREENCHE OU NÃO OS CAMPOS REFERENTE A PAUTA
	lPauta	:= .F.
	If substr((cAliasCL8)->CKZ_COD,3,1) == '3'
		lPauta	:= .T.
	EndIF

	//VERIFICAÇÃO DO INDICADOR DE UTILIZAÇÃO DO CRÉDITO
	cIndic	:= '0' //UTILIZAÇÃO TOTAL DO CRÉDITO
	If (cAliasCL8)->CL8_TOTCRD <> (cAliasCL8)->CL8_CRDUTI
		cIndic	:= '1' //UTILIZAÇÃO PARCIAL DO CRÉDITO
	EndIF

	oM100M500:setRelac(cGrupoM010)
	oM100M500:setCodCrd((cAliasCL8)->CKZ_COD)
	oM100M500:setOriCrd((cAliasCL8)->CL8_INDCRE)
	IF (cAliasCL8)->CL8_INDCRE =='1'
		oM100M500:setBasCalc('')
		oM100M500:setAlq('')
		oM100M500:setBaCalcQ('')
		oM100M500:setAlqR('')
	Else
		oM100M500:setBasCalc(Iif(lPauta,'',(cAliasCL8)->CL8_BSCALC))
		oM100M500:setAlq(Iif(lPauta,'',(cAliasCL8)->CKZ_ALIQ))
		oM100M500:setBaCalcQ( Iif(lPauta,(cAliasCL8)->CL8_BSCALC,''))
		oM100M500:setAlqR(Iif(lPauta,(cAliasCL8)->CKZ_ALIQ,''))
	Endif
	oM100M500:setCrdApur((cAliasCL8)->CL8_VLCRED)
	oM100M500:setAjuAcr((cAliasCL8)->CL8_AJAC)
	oM100M500:setAjuRed((cAliasCL8)->CL8_AJRD)
	oM100M500:setCrdDif((cAliasCL8)->CL8_DIF)
	oM100M500:setCrdDisp((cAliasCL8)->CL8_TOTCRD)
	oM100M500:setIndUti(cIndic)
	oM100M500:setCrdDesc((cAliasCL8)->CL8_CRDUTI)
	oM100M500:setSldCrd((cAliasCL8)->CL8_TOTCRD - (cAliasCL8)->CL8_CRDUTI )

	//VERIFICAÇÃO PARA CHAMAR MÉTODO DE PIS OU MÉTODO DE COFINS
	If (cAliasCL8)->CKZ_TRIB == PIS
		//PIS
		oM100M500:AddM100()
		cChv100500		:=oM100M500:getGrupo()
		//Quando M100 for de origem 1 – Evento de incorporação, cisão ou fusão não deve gerar filhos.
		IF !(cAliasCL8)->CL8_INDCRE =='1'
			//CHAMAR FUNÇÃO PARA GERAÇÃO DOS REGISTROS FILHOS DE M100
			PrcM105505(cChv100500, dDataDe, (cAliasCL8)->CL8_CHV, PIS,oM100M500,oBloco0,oTabela,lConcFil,(cAliasCL8)->CL8_CODBCC,lConsol)

			If ((cAliasCL8)->CL8_AJAC > 0 .OR. ((cAliasCL8)->CL8_AJRD > 0)) .And. cChave != (cAliasCL8)->CL8_CHV
				//PROCESSA AJUSTE DE CRÉDITO DE PIS
				PrcAjuBlcM(cChv100500, (cAliasCL8)->CL8_CHV, PIS, CREDITO,oM100M500,oBloco0,oTabela,lConcFil,lConsol,lDetAju, .F., .F.)
				cChave := (cAliasCL8)->CL8_CHV
			EndIF
		Endif

	ElseIF (cAliasCL8)->CKZ_TRIB == COFINS
		//COFINS
		oM100M500:AddM500()
		cChv100500		:=oM100M500:getGrupo()

		//Quando M100 for de origem 1 – Evento de incorporação, cisão ou fusão não deve gerar filhos.
		IF !(cAliasCL8)->CL8_INDCRE =='1'
			//CHAMAR FUNÇÃO PARA GERAÇÃO DOS REGISTROS FILHOS DE M500
			PrcM105505(oM100M500:getGrupo(), dDataDe,(cAliasCL8)->CL8_CHV, COFINS,oM100M500,oBloco0,oTabela,lConcFil,(cAliasCL8)->CL8_CODBCC,lConsol)

			If ((cAliasCL8)->CL8_AJAC > 0 .OR. (cAliasCL8)->CL8_AJRD > 0) .And. cChave != (cAliasCL8)->CL8_CHV
				//PROCESSA AUSTE DE CRÉDITO DE COFINS
				PrcAjuBlcM(cChv100500, (cAliasCL8)->CL8_CHV, COFINS, CREDITO,oM100M500,oBloco0,oTabela,lConcFil,lConsol,lDetAju, .F., .F.)
				cChave := (cAliasCL8)->CL8_CHV
			EndIF
		Endif
	EndIF

	(cAliasCL8)->(DbSkip ())
EndDo
DbSelectArea (cAliasCL8)
(cAliasCL8)->(DbCloseArea())

oTabela:GrvReg(oM100M500:getM100())


oTabela:GrvReg(oM100M500:getM105())


oTabela:GrvReg(oM100M500:getM110())


oTabela:GrvReg(oM100M500:getM500())


oTabela:GrvReg(oM100M500:getM505())


oTabela:GrvReg(oM100M500:getM510())

If lDetAju
	oTabela:GrvReg(oM100M500:getM115())
	oTabela:GrvReg(oM100M500:getM515())

	oTabela:GrvReg(oM100M500:getM225())
	oTabela:GrvReg(oM100M500:getM625())
EndIF


FreeObj(oM100M500)
oM100M500:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM100500()
@description Esta função irá processar as informações e valores dos registros
			   M105 e M505, gravados na tabela CLA
@param cGrupoMX00,String,Relação com registro pai M100/M500.
@param cChave,String,Chave de relação da tabela CL8 com CL9.
@param cTrib,String,Indica o tributo processado: 1-PIS / 2-COFINS
@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function PrcM105505(cGrupoMX00, dDataDe,cChave, cTrib, oM105M505,oBloco0,oTabela,lConcFil,cCodBcc,lConsol)

Local cAliasCL9	:= 'CL9'
Local cCampos		:= ''
Local cFiltro		:= ''
Local cIndex
Local lProc	:= .T.

IF	CL9->(MsSeek (xFilial ("CL9")+dTos(dDataDe)+cChave))

	cChave := CL9->CL9_FILIAL+DTOS(CL9->CL9_PER)+CL9->CL9_CHV

	Do while !CL9->(Eof()) .And. CL9->CL9_FILIAL+DTOS(CL9->CL9_PER)+CL9->CL9_CHV==cChave
		IF lConsol
			lProc	:= CL9->CL9_CONSOL == '1'
		Else
			lProc	:= CL9->CL9_CONSOL == '2'
		EndIF

		If CL9->CL9_CODBCC== cCodBcc .AND. lProc
			oM105M505:setRelac(cGrupoMX00)
			oM105M505:setCodBcc(CL9->CL9_CODBCC)
			oM105M505:setCST(CL9->CL9_CST)
			oM105M505:setBasACDF(Iif(CL9->CL9_PAUTA == '1','',CL9->CL9_TOTBSE))
			oM105M505:setBasCum(Iif(CL9->CL9_PAUTA == '1','',CL9->CL9_BSCUM))
			//aBAIXO É VERIFICADO SE OPERAÇÃO COM PAUTA, PARA PREENCHER OS RESPECTIVOS CAMPOS DE BASE EM QUANTIDADE E ALÍQUOTA EM REAIS
			oM105M505:setBasNCum(Iif(CL9->CL9_PAUTA == '1','',CL9->CL9_BSNCUM))
			oM105M505:setBasCalc(Iif(CL9->CL9_PAUTA == '1','',CL9->CL9_BSTCRD))
			oM105M505:setBsQACDF(Iif(CL9->CL9_PAUTA == '1',CL9->CL9_BSNCUM,''))
			oM105M505:setBaCalcQ(Iif(CL9->CL9_PAUTA == '1',CL9->CL9_BSTCRD,''))
			oM105M505:setDescr(CL9->CL9_DESCR)

			If cTrib == PIS
				//Chama método para processar informações do registro M105
				oM105M505:AddM105()

			ElseIF cTrib == COFINS
				//Chama método para processar informações do registro M505
				oM105M505:AddM505()


			EndIF
		EndIF

		CL9->(DbSkip())
	Enddo

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcAjuBlcM()
@description Esta função processa os ajustes de redução ou acréscimo no bloco M
			Seja de crédito ou de débito, nos registros M110/M510/M220 e M620.
@param cGrupoPai,String,Relação com registro pai M105/M505/M210/M610
@param cChave,String,Chave de relação com registro pai
@param cTrib,String,Indica o tributo processado: 1-PIS / 2-COFINS
@param cDebCred,String,Indica se o ajuste é de 1=Crédito ou 2=Débito

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function PrcAjuBlcM(cGrupoPai, cChave, cTrib, cDebCred,oAjuste,oBloco0,oTabela,lConcFil,lConsol,lDetAju,lAjuBase,lCmpAjuBC)

Local lProc		:= .T.
Local cChaveF2Z	:= ""
Local cConta	:= ""
Local cFilOri   := ""

//Processamento para geração dos registros de ajustes de base de cálculo
If lAjuBase .AND. lCmpAjuBC

	DbSelectArea ('F2Z')
	F2Z->(DbSetOrder(2)) //F2Z_FILIAL + F2Z_CHV + F2Z_ORIG

	//Aqui busco todos F2Z que foram gerados automaticamente pela apuração
	IF	F2Z->(MsSeek (xFilial ("F2Z")+cChave+"2"))
		cChaveF2Z	:= F2Z->F2Z_FILIAL + F2Z->F2Z_CHV + F2Z->F2Z_ORIG

		Do while !F2Z->(Eof()) .And. F2Z->F2Z_FILIAL + F2Z->F2Z_CHV + F2Z->F2Z_ORIG == cChaveF2Z

			cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,F2Z->F2Z_CONTA,,.F.)

			oAjuste:setRelac(cGrupoPai)
			oAjuste:setIndAju(F2Z->F2Z_INDAJU)
			oAjuste:setValAju(F2Z->F2Z_VALAJU)
			oAjuste:setCodAju(F2Z->F2Z_CODAJU)
			oAjuste:setNumDoc(F2Z->F2Z_NUM)
			oAjuste:setDescr(F2Z->F2Z_DESCR)
			oAjuste:setDtOper(F2Z->F2Z_DTREF)
			oAjuste:setCodCtb(cConta)
			oAjuste:setCNPJ(F2Z->F2Z_CNPJ)
			oAjuste:setInfComp(F2Z->F2Z_COMPL)

			IF cTrib == PIS
				oAjuste:AddM215()
			ElseIf cTrib == COFINS
				oAjuste:AddM615()
			EndIF

			F2Z->(DbSkip())
		EndDo

	EndIF

EndIF

IF	CLA->(MsSeek (xFilial ("CLA")+cChave))

	cChave := CLA->CLA_FILIAL+CLA->CLA_CHV

	cFilOri := CLA->CLA_FILIAL

	Do while !CLA->(Eof()) .And. CLA->CLA_FILIAL+CLA->CLA_CHV==cChave

		IF lConsol
			lProc	:= CLA->CLA_CONSOL == '1'
		Else
			lProc	:= CLA->CLA_CONSOL == '2'
		EndIF
		IF lProc

			/* Adotado a criação do campo CLA->CLA_FILORI, para solucionar o problema de geração dos 
			   Detalhamentos de Ajuste M225/M625 originados da tabela CL4, evitando a necessidade de 
			   realizar a consolidação/duplicação dos registros (padrão), evitando também a alteração
			   de regras de numeração com GetSXENUM() na tabela CLA.
			*/
			If CLA->(FieldPos("CLA_FILORI"))>0 .and. !empty(CLA->CLA_FILORI)
				cFilOri := CLA->CLA_FILORI
			Endif

			oAjuste:setRelac(cGrupoPai)
			oAjuste:setIndAju(CLA->CLA_TPAJU)
			oAjuste:setValAju(CLA->CLA_VLAJU)
			oAjuste:setCodAju(CLA->CLA_COD)
			oAjuste:setNumDoc(CLA->CLA_NUM)
			oAjuste:setDescr(CLA->CLA_DESCR)
			oAjuste:setDtOper(CLA->CLA_DTREF)

			IF cTrib == PIS
				IF cDebCred == CREDITO
					//AJUSTE DE CRÉDITO DE PIS
					oAjuste:AddM110()
					IF lDetAju
						//Processa o registro de detalhamento do ajuste
						PrcDetAjuM(oAjuste:getGrupo(), cFilOri + CLA->CLA_CHV+CLA->CLA_ID, PIS, CREDITO,oAjuste,oBloco0,oTabela,lConcFil)
					EndIF

				ElseIF cDebCred == DEBITO
					//AJUSTE DE DÉBITO DE PIS
					oAjuste:AddM220()

					IF lDetAju
						//Processa o registro de detalhamento do ajuste
						PrcDetAjuM(oAjuste:getGrupo(), cFilOri + CLA->CLA_CHV+CLA->CLA_ID, PIS, DEBITO,oAjuste,oBloco0,oTabela,lConcFil)
					EndiF

				EndIF
			ElseIf cTrib == COFINS
				IF cDebCred == CREDITO
					//AJUSTE DE CRÉDITO DE COFINS
					oAjuste:AddM510()

					IF lDetAju
						//Processa o registro de detalhamento do ajuste
						PrcDetAjuM(oAjuste:getGrupo(), cFilOri + CLA->CLA_CHV+CLA->CLA_ID, COFINS, CREDITO, oAjuste,oBloco0,oTabela,lConcFil)
					EndIF

				ElseIF cDebCred == DEBITO
					//AJUSTE DE DÉBITO DE COFINS
					oAjuste:AddM620()

					IF lDetAju
						//Processa o registro de detalhamento do ajuste
						PrcDetAjuM(oAjuste:getGrupo(), cFilOri + CLA->CLA_CHV+CLA->CLA_ID, COFINS, DEBITO, oAjuste,oBloco0,oTabela,lConcFil)
					EndIF

				EndIF
			EndIF
		EndIF

		CLA->(DbSkip())
	EndDo

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcDetAjuM()
@description Esta função processa o detalhamento dos ajustes em M110/M510/M220/M620
@param cGrupoPai,String,Relação com registro pai M110/M510/M210/M610
@param cChave,String,Chave de relação com registro pai
@param cTrib,String,Indica o tributo processado: 1-PIS / 2-COFINS
@param cDebCred,String,Indica se o ajuste é de 1=Crédito ou 2=Débito

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function PrcDetAjuM(cGrupoPai, cChave, cTrib, cDebCred,oDetAjuste,oBloco0,oTabela,lConcFil)

Local cAliasCL4	:= 'CL4'
Local cConta	    := ''

DbSelectArea ('CL4')
CL4->(DbSetOrder (2))

IF	CL4->(MsSeek(cChave))

	Do while !CL4->(Eof()) .And. CL4->CL4_FILIAL+CL4->CL4_CHV+CL4->CL4_IDCLA==cChave

		cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,SubStr(CL4->CL4_CODCTA,1,TAMSX3("CT1_CONTA")[1]),,.F.)

		oDetAjuste:setRelac(cGrupoPai)
		oDetAjuste:setValAju(CL4->CL4_VLAJU)
		oDetAjuste:setCST(CL4->CL4_CST)
		oDetAjuste:setBasCalc(CL4->CL4_BASE)
		oDetAjuste:setAlq(CL4->CL4_ALQ)
		oDetAjuste:setDtOper(CL4->CL4_DATA)
		oDetAjuste:setDescr(CL4->CL4_DESC)
		oDetAjuste:setCodCtb(cConta)
		oDetAjuste:setInfComp(CL4->CL4_INFO)

		IF cTrib == PIS
			IF cDebCred == CREDITO
				//AJUSTE DE CRÉDITO DE PIS
				oDetAjuste:AddM115()
			ElseIF cDebCred == DEBITO
				//AJUSTE DE DÉBITO DE PIS
				oDetAjuste:AddM225()
			EndIF
		ElseIf cTrib == COFINS
			IF cDebCred == CREDITO
				//AJUSTE DE CRÉDITO DE COFINS
				oDetAjuste:AddM515()
			ElseIF cDebCred == DEBITO
				//AJUSTE DE DÉBITO DE COFINS
				oDetAjuste:AddM625()
			EndIF
		EndIF

		CL4->(DbSkip())
	EndDo

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM200500()
@description Função que irá processar as informações dos registros M200 e
			  M600.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoM010,String,Relação com registro pai M010

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Function PrcM200600(dDataDe, dDataAte, cGrupoM010,oTabela,aNumeracao,oBloco0,lConcFil,lConsol,aSM0,lDetAju,cIndNatPJ,lAjuBase, lCmpAjuBC)

Local oM200M600	:= EFDCBLOCOM():New()
Local cAliasCKR	:= 'CKR'
Local cCampos		:= ''
Local cFiltro		:= ''
Local cGrupoReg	:= ''
Local cChave		:= ''
Local lProc		:= .T.

Default lAjuBase	:= .F.
Default lCmpAjuBC	:= .F.

oM200M600:setaNumer(aNumeracao)

IF	CKR->(MsSeek (xFilial ("CKR")+dTos(dDataDe)))

	cChave := CKR->CKR_FILIAL+DTOS(CKR->CKR_PER)

	Do while !CKR->(Eof()) .And. CKR->CKR_FILIAL+DTOS(CKR->CKR_PER) == cChave

		IF lConsol
			lProc	:= CKR->CKR_CONSOL == '1'
		Else
			lProc	:= CKR->CKR_CONSOL == '2'
		EndIF

		IF lProc
			oM200M600:setRelac(cGrupoM010)
			oM200M600:setVlNCum(CKR->CKR_CONNC)
			oM200M600:setCrduTiP(CKR->CKR_CRDATU)
			oM200M600:setCrduTiA(CKR->CKR_CRDANT)
			oM200M600:setTotConN((CKR->CKR_CONNC - (CKR->CKR_CRDATU + CKR->CKR_CRDANT)))
			oM200M600:setVlRetN(CKR->(CKR_RTANTN + CKR_RTATUN))
			oM200M600:setOutNCum(CKR->CKR_OUTDNC)
			oM200M600:setNCumRec(CKR->CKR_NCREC)
			oM200M600:setVlCum(CKR->CKR_CONC)
			oM200M600:setVlRetC(CKR->(CKR_RTANTC + CKR_RTATUC))
			oM200M600:setOutCum(CKR->CKR_OUTDC)
			oM200M600:setCumRec(CKR->CKR_CREC)
			oM200M600:setTotPag(CKR->(CKR_NCREC+CKR_CREC))

			If CKR->CKR_TRIB == PIS
				//PROCESSA INFORMAÇÕES PASSADAS NO REGISTRO M200
				oTabela:GrvReg(oM200M600:AddM200())

				//Realiza a chamada da função do registro M205
				PrcM205505(dDataDe, dDataAte, oM200M600:getGrupo(),'M205',oTabela,oM200M600,lConsol)
				PrcM210610(dDataDe, dDataAte, oM200M600:getGrupo(),'M210',oTabela,oM200M600,oBloco0,lConcFil,lConsol,aSM0,lDetAju,cGrupoM010,cIndNatPJ,lAjuBase,lCmpAjuBC)

			ElseIF CKR->CKR_TRIB == COFINS
				//PROCESSA INFORMAÇÕES PASSADAS NO REGISTRO M600
				oTabela:GrvReg(oM200M600:AddM600())
				oTabela:SetRegistr('M600')
				//Realiza a chamada da função do registro M205
				PrcM205505(dDataDe, dDataAte, oM200M600:getGrupo(),'M605',oTabela,oM200M600,lConsol)
				PrcM210610(dDataDe, dDataAte, oM200M600:getGrupo(),'M610',oTabela,oM200M600,oBloco0,lConcFil,lConsol,aSM0,lDetAju,cGrupoM010,cIndNatPJ,lAjuBase,lCmpAjuBC)

			EndIF
		EndIF

		CKR->(DbSkip())
	Enddo

EndIF

//Processa registro M300
ProcCFB(dDataDe, 'PIS',cGrupoM010, oM200M600,aSM0,lConsol)
//Processa registro M700
ProcCFB(dDataDe, 'COF',cGrupoM010, oM200M600,aSM0,lConsol)
oTabela:GrvReg(oM200M600:getM300())


oTabela:GrvReg(oM200M600:getM700())


FreeObj(oM200M600)
oM200M600:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM205505()
@description Função que irá processar as informações dos registros M205 e
			  M605. Saõ registros filhos dos registros M200 e M600
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoMX00,String,Relação com registro pai M200/M600

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function PrcM205505(dDataDe, dDataAte, cGrupoMX00, cReg ,oTabela ,oM205M605,lConsol)

Local cAliasCL3	:= 'CL3'
Local cCampos		:= ''
Local cFiltro		:= ''
Local nIndex		:= 0
Local cTrib			:= ''
Local lCL3TrbOri	:= CL3->(FieldPos('CL3_TRBORI'))>0
Local cIndex

DbSelectArea ('CL3')
CL3->(DbSetOrder (1))

cIndex		:= CriaTrab(NIL,.F.)
cFiltro    := " CL3_FILIAL=='"+ xFilial("CL3") + "' "

cFiltro    += " .AND. dTos(CL3_PER)>='"		+ dTos(dDataDe)		+"' "
cFiltro    += " .AND. dTos(CL3_PER)<='"		+ dTos(dDataAte)		+"' "

cFiltro    += " .AND. CL3_VALOR > 0 "

cFiltro    += " .AND. CL3_CODREC <> ' ' "

If cReg == 'M205'
	IF lCL3TrbOri
		//Se existir o campo CL3_TRBORI, então ele também deverá ser levado em consideração
		cFiltro 	+= " .AND. (CL3_TRIB $'1#2' .OR. CL3_TRBORI $'1#2')  " //TRAZ SOMENTE INFORMAÇÕES De PIS
	Else
		cFiltro 	+= " .AND. CL3_TRIB $'1#2' " //TRAZ SOMENTE INFORMAÇÕES De PIS
	EndIF
ElseIF cReg == 'M605'
	IF lCL3TrbOri
		//Se existir o campo CL3_TRBORI, então ele também deverá ser levado em consideração
		cFiltro 	+= " .AND. (CL3_TRIB $'3#4' .OR. CL3_TRBORI $'3#4')  " //TRAZ SOMENTE INFORMAÇÕES De COFINS
	Else
		cFiltro 	+= " .AND. CL3_TRIB $'3#4' " //TRAZ SOMENTE INFORMAÇÕES De COFINS
	EndIF
EndIF

IF lConsol
	cFiltro 	+= " .AND. CL3_CONSOL == '1' "
Else
	cFiltro 	+= " .AND. CL3_CONSOL == '2' "
EndIF

IndRegua (cAliasCL3, cIndex, CL3->(IndexKey ()),, cFiltro)
nIndex := RetIndex(cAliasCL3)

DbSelectArea(cAliasCL3)
DbSetOrder(nIndex+1)

DbSelectArea (cAliasCL3)
(cAliasCL3)->(DbGoTop ())
Do While !(cAliasCL3)->(Eof ())

	oM205M605:setRelac(cGrupoMX00)
	oM205M605:setCodRec((cAliasCL3)->CL3_CODREC)
	oM205M605:setTotPag((cAliasCL3)->CL3_VALOR)

	//O campo CL3_TRIB contém os tributos de 1 até 4, que são os códigos de receita padrão. Caso o usuário tenha
	//configurado regra para desmembrar valores em códigos diferentes, então deverá se atentar ao campo Cl3_TRBORI.
	//Abaixo preencho primeiro com o CL3_TRIB, porém se houver informação no CK3_TRBORI, então este terá maior prioridade
	cTrib	:= (cAliasCL3)->CL3_TRIB
	If lCL3TrbOri .AND. !EMPTY((cAliasCL3)->CL3_TRBORI)
		cTrib	:= (cAliasCL3)->CL3_TRBORI
	EndIF
	//VERIFICAÇÃO DO CAMPO QUE SE REFERE M205/M605.
	If cTrib $ '1/2'  //1=PIS NÃO CUMULATIVO - 2=PIS CUMULATIVO
		oM205M605:setNumCpo(Iif(cTrib == '1' ,'08' ,'12' ))
		oTabela:GrvReg(oM205M605:AddM205())


	ElseIF cTrib $ '3/4'  //3=COFINS NÃO CUMULATIVO - 4=COFINS CUMULATIVO
		oM205M605:setNumCpo(Iif(cTrib == '3' ,'08' ,'12' ))
		oTabela:GrvReg(oM205M605:AddM605())

	EndIF

	(cAliasCL3)->(DbSkip ())
EndDo
dbSelectArea("CL3")
RetIndex("CL3")
dbClearFilter()
FErase(cIndex+OrdBagExt())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM210610()
@description Função que irá processar as informações dos registros M210 e
			  M610. Saõ registros filhos dos registros M200 e M600
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoMX00,String,Relação com registro pai M200/M600

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function PrcM210610(dDataDe, dDataAte, cGrupoMX00, cReg, oTabela,oM210M610,oBloco0,lConcFil,lConsol,aSM0,lDetAju,cGrupoM010,cIndNatPJ,lAjuBase,lCmpAjuBC)

Local cAliasCKS	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local lPauta		:= .F.
Local cGrupoReg	:= ''
Local cChv210610	:= ''
Local aRegM210 := {}
Local aRegM610 := {}
Local nX := 0

Default cIndNatPJ	:=	mv_par11
Default lAjuBase	:= .F.
Default lCmpAjuBC	:= .F.

DbSelectArea ("CKZ")
CKZ->(DbSetOrder (1))

DbSelectArea ("CKS")
CKS->(DbSetOrder (1))

cCampos	:= '%CKZ.CKZ_TRIB	, CKZ.CKZ_ALIQ	, CKZ.CKZ_COD	, CKS.CKS_VLREC	, CKS.CKS_BASE ,'
cCampos	+= 'CKS.CKS_VLTRIB	, CKS.CKS_AJAC	, CKS.CKS_AJRD  , CKS.CKS_DIF   , CKS.CKS_DIFANT,'

//Se os novos campos de ajuste da base de cálculo existir na base irei adiciona na seção do select
IF lCmpAjuBC
	cCampos	+= 'CKS.CKS_AJBCA	, CKS.CKS_AJBCR	, CKS.CKS_BCAJUS, '
EndIF

cCampos	+= 'CKS.CKS_VLDISP	, CKS.CKS_PAUTA	, CKS.CKS_CHV%'
//JOIN COM TABELA CKS - CRÉDITOS CONSOLIDADOS
cJoin	:=	"INNER JOIN "+RetSqlName("CKS")+" CKS ON(CKS.CKS_FILIAL='"+xFilial("CKS")+"' AND CKS.CKS_CHV=CKZ.CKZ_ID AND CKS.CKS_CONSOL= '" +Iif(lConsol,'1','2') + "' and CKS.D_E_L_E_T_=' ') "
cJoin	:= '%' + cJoin + '%'

cFiltro 	:= "%"
cFiltro 	+= "CKZ.CKZ_FILIAL= '"+ xFilial('CKZ')+ "' AND "
cFiltro 	+= "CKZ.CKZ_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKZ.CKZ_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro 	+= "CKZ.CKZ_DEBCRD= '1' AND " //Somente trará operações com débitos
If cReg == 'M210'
	cFiltro 	+= "CKZ.CKZ_TRIB= '1' AND " //Somente trará operações de PIS
ElseIF cReg == 'M610'
	cFiltro 	+= "CKZ.CKZ_TRIB= '2' AND " //Somente trará operações de COFINS
EndIF

IF lConsol
	cFiltro 	+= "CKZ.CKZ_CONSOL= '1' AND "
Else
	cFiltro 	+= "CKZ.CKZ_CONSOL= '2' AND "
EndIF

cFiltro 	+= "%"

cAliasCKS	:=	GetNextAlias()
BeginSql Alias cAliasCKS

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKZ% CKZ
	%Exp:cJoin%
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%

EndSql

DbSelectArea (cAliasCKS)
(cAliasCKS)->(DbGoTop ())

Do While !(cAliasCKS)->(Eof ())

	lPauta	:= .F.
	If (cAliasCKS)->CKS_PAUTA == '1'
		lPauta	:= .T.
	EndIF

	If (cAliasCKS)->CKZ_COD <> '99'//verifica se não é pis sobre folha de salário

		oM210M610:setRelac(cGrupoMX00)
		oM210M610:setCodCon(Alltrim((cAliasCKS)->CKZ_COD))
		oM210M610:setVlBrut((cAliasCKS)->CKS_VLREC)
		oM210M610:setBasCalc(Iif(lPauta,0,(cAliasCKS)->CKS_BASE))
		oM210M610:setAlq(Iif(lPauta,0,(cAliasCKS)->CKZ_ALIQ))
		oM210M610:setBaCalcQ(Iif(lPauta,(cAliasCKS)->CKS_BASE,0))
		oM210M610:setAlqR(Iif(lPauta,(cAliasCKS)->CKZ_ALIQ,0))
		oM210M610:setVlConAp((cAliasCKS)->CKS_VLTRIB)
		oM210M610:setAjuAcr((cAliasCKS)->CKS_AJAC)
		oM210M610:setAjuRed((cAliasCKS)->CKS_AJRD)
		oM210M610:setConDif((cAliasCKS)->CKS_DIF)
		oM210M610:setConDifA((cAliasCKS)->CKS_DIFANT)
		oM210M610:setVlConPe((cAliasCKS)->CKS_VLDISP)
		oM210M610:setAjuBase(lAjuBase)

		//Se estiver vigente novos campos precisa chamar os novos métodos para gerar os campos de ajuste de base de cálculo
		IF lAjuBase .AND. lCmpAjuBC
			oM210M610:setAcreBC((cAliasCKS)->CKS_AJBCA)
			oM210M610:setReduBC((cAliasCKS)->CKS_AJBCR)
			oM210M610:setBCAJus((cAliasCKS)->CKS_BCAJUS)
		EndIF

		If (cAliasCKS)->CKZ_TRIB == PIS

			//GERA REGISTRO M210 PARA PIS
			oM210M610:AddM210()

			cChv210610	:=oM210M610:getGrupo()

			//Gera ajuste de débito de PIS
			PrcAjuBlcM(cChv210610, (cAliasCKS)->CKS_CHV, PIS, DEBITO,oM210M610,oBloco0,oTabela,lConcFil,lConsol,lDetAju,lAjuBase,lCmpAjuBC )

			IF (cAliasCKS)->CKS_DIF > 0 .or. (cAliasCKS)->CKS_DIFANT > 0
				ProcCFA(dDataDe, 'PIS',(cAliasCKS)->CKZ_COD,cChv210610, oM210M610,aSM0,lConsol)
			EndIF

		ElseIF (cAliasCKS)->CKZ_TRIB == COFINS

			//GERA REGISTRO M610 PARA COFINS
			oM210M610:AddM610()

			cChv210610	:=oM210M610:getGrupo()

			//Gera ajuste de débito de COFINS
			PrcAjuBlcM(cChv210610, (cAliasCKS)->CKS_CHV, COFINS, DEBITO,oM210M610,oBloco0,oTabela,lConcFil,lConsol,lDetAju,lAjuBase,lCmpAjuBC )

			IF (cAliasCKS)->CKS_DIF > 0 .or. (cAliasCKS)->CKS_DIFANT > 0
				ProcCFA(dDataDe, 'COF',(cAliasCKS)->CKZ_COD,cChv210610, oM210M610,aSM0,lConsol)
			EndIF

		EndIF


	ElseIF Alltrim((cAliasCKS)->CKZ_COD) == '99'//verifica se é pis sobre folha de salário

		//GERA registro M350. As informações ficam gravadas na tabela CKS, porém é única
		//operação com código da contribuição 99, que não tem relação com os demais
		oM210M610:setRelac(cGrupoM010)
		oM210M610:setTotFol((cAliasCKS)->CKS_VLREC)
		oM210M610:setExcFol((cAliasCKS)->CKS_AJRD)
		oM210M610:setBasCalc((cAliasCKS)->CKS_BASE)
		oM210M610:setAlq((cAliasCKS)->CKZ_ALIQ)
		oM210M610:setTotPag((cAliasCKS)->CKS_VLDISP)

		//Processa registro M350 sobre pis salários
		oM210M610:AddM350()
	EndIF

	(cAliasCKS)->(DbSkip ())

EndDo

DbSelectArea (cAliasCKS)
(cAliasCKS)->(DbCloseArea())

IF cReg	 == 'M210'

	// Geracao do registro M211 - Se foi selecionado sociedade cooperativa na Wizard.
	If cIndNatPJ $ "01-04"
		aRegM210 := oM210M610:getM210()
		For nX := 1 to Len(aRegM210)
			If lAjuBase
				ProcCE9(aRegM210[nX,1],dDataDe,aRegM210[nX,3],cValtochar(aRegM210[nX][9,1]),aRegM210[nX,4],oM210M610,'PIS')
			Else
				ProcCE9(aRegM210[nX,1],dDataDe,aRegM210[nX,3],cValtochar(aRegM210[nX][6,1]),aRegM210[nX,4],oM210M610,'PIS')
			EndiF
		Next nX
	EndIF

	//-------------------------------------------------------------------
	//Grava regisregistro M210
	//-------------------------------------------------------------------
	oTabela:GrvReg(oM210M610:getM210())

	oTabela:GrvReg(oM210M610:getM211())

	If lAjuBase
		oTabela:GrvReg(oM210M610:getM215())
	EndIF

	//-------------------------------------------------------------------
	//Grava regisregistro M220
	//-------------------------------------------------------------------
	oTabela:GrvReg(oM210M610:getM220())

	//-------------------------------------------------------------------
	//Grava regisregistro M225
	//-------------------------------------------------------------------

	oTabela:GrvReg(oM210M610:getM225())


	//-------------------------------------------------------------------
	//Grava regisregistro M230
	//-------------------------------------------------------------------

	oTabela:GrvReg(oM210M610:getM230())

	oTabela:GrvReg(oM210M610:getM350())


ElseIF cReg == 'M610'

	// Geracao do registro M611 - Se foi selecionado sociedade cooperativa na Wizard.
	If cIndNatPJ $ "01-04"
		aRegM610 := oM210M610:getM610()
		For nX := 1 to Len(aRegM610)
			If lAjuBase
				ProcCE9(aRegM610[nX,1],dDataDe,aRegM610[nX,3],cValtochar(aRegM610[nX][9,1]),aRegM610[nX,4],oM210M610,'COF')
			Else
				ProcCE9(aRegM610[nX,1],dDataDe,aRegM610[nX,3],cValtochar(aRegM610[nX][6,1]),aRegM610[nX,4],oM210M610,'COF')
			EndIf
		Next nX
	EndIF

	//-------------------------------------------------------------------
	//Grava regisregistro M2610
	//-------------------------------------------------------------------
	oTabela:GrvReg(oM210M610:getM610())

	oTabela:GrvReg(oM210M610:getM611())

	If lAjuBase
		oTabela:GrvReg(oM210M610:getM615())
	EndIF

	//-------------------------------------------------------------------
	//Grava regisregistro M620
	//-------------------------------------------------------------------
	oTabela:GrvReg(oM210M610:getM620())

	//-------------------------------------------------------------------
	//Grava regisregistro M625
	//-------------------------------------------------------------------
	oTabela:GrvReg(oM210M610:getM625())


	//-------------------------------------------------------------------
	//Grava regisregistro M630
	//-------------------------------------------------------------------

	oTabela:GrvReg(oM210M610:getM630())

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM400800
@description Função para processar registros M400 e M800, referente aos valores
			   não tributado de PIS e COFINS.
@param	dDataDe,Date,Dia inicial da geração do arquivo
@param	dDataAte,Date,Dia final da geração do arquivo
@param cGrupoM010,String,Relação com registro pai M010

@author Erick G. Dias
@since 10/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcM400800(dDataDe, dDataAte, cGrupoM010,oTabela,aNumeracao,oBloco0,lConcFil,lConsol)

Local oM400M800		:= EFDCBLOCOM():New()
Local cAliasCKT	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cConta		:= ''

cCampos	:= '%CKT.CKT_CST		, CKT.CKT_VLREC	, CKT.CKT_CONTA, CKT.CKT_DESCR,'
cCampos	+= 'CKT.CKT_CODNAT	, CKT.CKT_TRIB	%'

cFiltro 	:= "%"
cFiltro 	+= "CKT.CKT_FILIAL= '"+ xFilial('CKT')+ "' AND "
cFiltro 	+= "CKT.CKT_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro 	+= "CKT.CKT_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "

If lConsol
	cFiltro 	+= "CKT.CKT_CONSOL = '1' AND "
Else
	cFiltro 	+= "CKT.CKT_CONSOL = '2' AND "
EndIF

cFiltro 	+= "%"

cAliasCKT	:=	GetNextAlias()
BeginSql Alias cAliasCKT

	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKT% CKT
	WHERE
	%Exp:cFiltro%
	CKT.%NotDel%

EndSql

DbSelectArea (cAliasCKT)
(cAliasCKT)->(DbGoTop ())

oM400M800:setaNumer(aNumeracao)

Do While !(cAliasCKT)->(Eof ())

	cConta	:= FSA0080500('', oBloco0,oTabela,lConcFil,(cAliasCKT)->CKT_CONTA,,.F.)

	oM400M800:setRelac(cGrupoM010)
	oM400M800:setCST((cAliasCKT)->CKT_CST)
	oM400M800:setVlBrut((cAliasCKT)->CKT_VLREC)
	oM400M800:setCodCtb(cConta)
	oM400M800:setDescr((cAliasCKT)->CKT_DESCR)

	//VERIFICA O TRIBUTO ABAIXO PARA DECIDIR SE GERA M400 OU M800
	If (cAliasCKT)->CKT_TRIB == PIS
		//REGISTROS DE PIS
		oM400M800:AddM400()
	ElseIF (cAliasCKT)->CKT_TRIB == COFINS
		//REGISTROS DE COFINS
		oM400M800:AddM800()
	EndIF

	oM400M800:setRelac(oM400M800:getGrupo())
	oM400M800:setCNatRec((cAliasCKT)->CKT_CODNAT)
	oM400M800:setVlBrut((cAliasCKT)->CKT_VLREC)
	oM400M800:setCodCtb(cConta)
	oM400M800:setDescr((cAliasCKT)->CKT_DESCR)

	//VERIFICA O TRIBUTO ABAIXO PARA DECIDIR SE GERA M400 OU M800
	If (cAliasCKT)->CKT_TRIB == PIS
		//REGISTROS DE PIS
		oM400M800:AddM410()
	ElseIF (cAliasCKT)->CKT_TRIB == COFINS
		//REGISTROS DE COFINS
		oM400M800:AddM810()
	EndIF

	(cAliasCKT)->(DbSkip ())
EndDo
DbSelectArea (cAliasCKT)
(cAliasCKT)->(DbCloseArea())

oTabela:GrvReg(oM400M800:getM400())


oTabela:GrvReg(oM400M800:getM410())


oTabela:GrvReg(oM400M800:getM800())


oTabela:GrvReg(oM400M800:getM810())


FreeObj(oM400M800)
oM400M800:= nil


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcA100
@description Função para processar as informações de nota de serviço no
			   registro A100
@param cChaveA010,String,Relação com registro pai A010
@param oA100,Objeto,Objeto da classe EFDCBLOCOA
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcA100(cChaveA010,oA100,cAliasSFT,cCodPart,cIndPagto,lSPDPIS05,lMVCF3ENTR,cEspecie, cEFDSerie,lMT)

Local cIndOper	:= ''
Local cNumNf	:= ''
Local cSerie	:= ''
Local cIndEmi	:= ''
Local cSituaDoc	:= ''
Local dDtExec	:= oA100:getDtAte()
Local lRet		:= 0
Local aSpeda100	:= {}
Local aCmpAntSFT:= {}

//Trata indicador de movimento, entrada =1, saída =2
cIndOper	:=	IndMovto((cAliasSFT)->FT_TIPOMOV)

If cIndPagto == '2'
	cIndPagto	:= '9'
EndiF

//³Ponto de entrada para o campo 13(IND_PAGTO)
If lSPDPIS05
	aCmpAntSFT		:={	(cAliasSFT)->FT_NFISCAL,;
					(cAliasSFT)->FT_SERIE,;
					(cAliasSFT)->FT_CLIEFOR,;
					(cAliasSFT)->FT_LOJA,;
					Iif((cIndOper=="2" .And. lMVCF3ENTR) .Or.cIndOper=="1",(cAliasSFT)->FT_ENTRADA,CToD("  /  /  ")),;		//05
					(cAliasSFT)->FT_EMISSAO,;
					(cAliasSFT)->FT_DTCANC,;
					(cAliasSFT)->FT_FORMUL,;
					(cAliasSFT)->FT_CFOP}

   	aSpeda100 := ExecBlock("SPDPIS05", .F., .F., {"SFT",aCmpAntSFT,0,cIndPagto,nil})
	cIndPagto := aSpeda100[1]
Endif

cSerie	:= ProcSerie( (cAliasSFT)->FT_SERIE, cEspecie, cEFDSerie)
/*Verifica se número da chave eletrônica está vazio.
Se estiver vazio indica que ainda trata-se do RPS, irá utilizar FTNFISCAL.
Se FT_NFELETR estiver preenchido, então o RPS foi de fato transmitido, e deverá
considerar a chave eletrônica.*/
If Empty((cAliasSFT)->FT_NFELETR)
	cNumNf:= (cAliasSFT)->FT_NFISCAL
Else
	cNumNf:= (cAliasSFT)->FT_NFELETR
	If 	Alltrim((cAliasSFT)->FT_ESPECIE) == "RPS" .AND. cSerie == (cAliasSFT)->FT_SERIE
		cSerie := "NFSE"
	EndIf
EndIF

/*Por padrão a data de execução do serviço será o último dia do mês
porém pode ser alterado através do parâmetro MV_DESBASC, para considerar
a emissão como data de execução do serviço*/

If (cAliasSFT)->FT_TIPOMOV == 'S' .AND. (cAliasSFT)->(FieldPos('F2_DTESERV')) > 0 .AND. (cAliasSFT)->F2_DTESERV <>  CToD("  /  /  ")
	dDtExec	:= (cAliasSFT)->F2_DTESERV
ElseIF (cAliasSFT)->FT_TIPOMOV == 'E' .AND. (cAliasSFT)->(FieldPos('F1_DTCPISS')) > 0 .AND. (cAliasSFT)->F1_DTCPISS <>  CToD("  /  /  ")
	dDtExec	:= (cAliasSFT)->F1_DTCPISS
ElseIF GetNewPar('MV_DESBASC', '1') == '2'
	dDtExec	:= (cAliasSFT)->FT_EMISSAO
EndIF

//Chama função para definir indicador de emissão do documento
cIndEmi:=IndEmit((cAliasSFT)->FT_FORMUL, cIndOper)

//Aqui chama função do SPEDXFUN para verificar situação do documento
cSituaDoc		:=	SPEDSitDoc (, cAliasSFT,,,oA100:getDtDe(),oA100:getDtAte(),,,,,,.T.)

/*
Tratamento para situação 03 (Cancelamento de NF-e homologado fora de prazo),
04 (Uso denegado) e 05 (Numeracao Inutilizada): Caso o retorno seja uma destas,
considerar o documento como "Cancelado" (02) pois o campo COD_SIT do registro
A100 só aceita as situações "00" (regular) e "02" (cancelado).
*/

If cSituaDoc $ "03|04|05"
	cSituaDoc := "02"
EndIf

//08 Significa regime especial, porém como no registro A100 o layout soment permite 00 - Regular ou 02 - Cancelado, irei adotar retorno 08 como situação noemal 00 para que o arquivo seja validado
If cSituaDoc == '08'
	cSituaDoc	:= "00"
EndIf

//Passa informações do cabeçalho do A170
oA100:setRelac(cChaveA010)
oA100:setIndOper(Iif ("E"$(cAliasSFT)->FT_TIPOMOV, '0', '1'))
oA100:setIndEmit(cIndEmi)
oA100:setCodPart(cCodPart)
oA100:setnSitDoc(cSituaDoc)
oA100:setnSerie(cSerie)
oA100:setnNumNf(cNumNf)
oA100:setChvNfe(Iif(cEspecie=="  ",(cAliasSFT)->FT_CODNFE,(cAliasSFT)->FT_CHVNFE))
oA100:setEmissao((cAliasSFT)->FT_EMISSAO)
oA100:setExec(dDtExec)
oA100:setIndPgto(cIndPagto)
lRet	:= oA100:AddA100(.T.,,lMT)

/*Os valores deste registro são obtidos com a soma dos valores do registro FIlho A170
//por este motivo não passo aqui os valores para o A100, somente os valores de cabeçalho
//O método oA100:AddA100() deverá ser executado somente quando finalizar todos os itens da nota.*/

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcA170
@description Função para processar as informações de nota de serviço no
			   registro A100
@param cChaveA100,String,Relação com registro pai A100
@param oA170,Objeto,Objeto da classe EFDCBLOCOA
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcA170(cChaveA100, oA170, cAliasSFT, nPosPai,cCusto,cConta,cCodProd,cDescProd)

Local cOrigCred	:= ''
Local nValDesc	:= 0
Local nVlPis		:= 0
Local nVlCof		:= 0
Local nAlqPis		:= 0
Local nAlqCof		:= 0

nVlPis		:= (cAliasSFT)->FT_VALPIS
nAlqPis	:= (cAliasSFT)->FT_ALIQPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqCof	:= (cAliasSFT)->FT_ALIQCOF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0
		nVlCof		-= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIF

IF (cAliasSFT)->FT_TIPOMOV == 'E'
	/*Verificação para idenbtificar a origem do crédito
	0-Mercado interno/1-Operação de exportação
	*/
	If SubStr((cAliasSFT)->FT_CFOP,1,1) == "3"
		cOrigCred:="1"
	Else
		cOrigCred:="0"
	EndIf
EndIF
/*
Valor do desconto do item:
Se o campo PISCRED for igual a 5-Exclusão de base de cálculo, irá descontar o valor
integral da base de cálculo, devido ao tratamento de prestador de serviço de propaganda pública.
Neste caso o valor da base de cálculo deverá ser reduzida totalmente. A gravação da base de cálculo
é efetuada de forma correta na MATXFIS, aqui somente devemos demosntrar o valor da base de cálculo
como desconto.
Caso contrário irá considerar o valor de desconto do item FT_DESCONT
*/
If (cAliasSFT)->F4_PISCRED == "5"
	nValDesc	:= (cAliasSFT)->FT_TOTAL
Else
	nValDesc	:= (cAliasSFT)->FT_DESCONT
EndiF

//Passa informnações para objeto para geração do A1170
oA170:setRelac(cChaveA100)
oA170:setCodItem(cCodProd)
oA170:setDescri(cDescProd)
oA170:setValItem((cAliasSFT)->FT_TOTAL)
oA170:setiVaDesc(nValDesc)
oA170:setiCodBcc((cAliasSFT)->FT_CODBCC)
oA170:setOriCrd(cOrigCred)
oA170:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oA170:setiBasPis((cAliasSFT)->FT_BASEPIS)
oA170:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oA170:setiBasCof((cAliasSFT)->FT_BASECOF)
oA170:setiAlqPis(nAlqPis)
oA170:setiValPis(nVlPis)
oA170:setiAlqCof(nAlqCof)
oA170:setiValCof(nVlCof)
oA170:setConta(cConta)
oA170:setiCCusto(cCusto)
oA170:AddA170() //Gravar A170

//---------------------------------------------------------------------------
//Abaixo irá passar os valores para serem acumulados no registro de nota A100
//---------------------------------------------------------------------------
oA170:setValorNf((cAliasSFT)->FT_VALCONT)
oA170:setnVlDesc(nValDesc)
oA170:setnBasPis((cAliasSFT)->FT_BASEPIS)
oA170:setnValPis(nVlPis)
oA170:setnBasCof((cAliasSFT)->FT_BASECOF)
oA170:setnValCof(nVlCof)
oA170:setPisRet((cAliasSFT)->FT_VRETPIS)
oA170:setCofRet((cAliasSFT)->FT_VRETCOF)
oA170:setValIss((cAliasSFT)->FT_VALICM)
oA170:AddA100(.F.,nPosPai)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcA120
@description Função para processar as informações de nota de serviço no
			   registro A120
@param ?,String,Relação com registro pai A100
@param oA120,Objeto,Objeto da classe EFDCBLOCOA
@param cAliasSFT,QUery,Query efetuado na SFT.
@param cAliasSD5,QUery,Query efetuado na SD5, com os complementos de importação.
@author Erick G. Dias
@since 11/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcA120(cChaveA100, oA120, cAliasSFT, cAliasCD5)

oA120:setRelac(cChaveA100)
oA120:setVImport((cAliasSFT)->FT_VALICM)
oA120:setBPisImp((cAliasCD5)->CD5_BSPIS)
oA120:setVPisImp((cAliasCD5)->CD5_VLPIS)
oA120:setDtPgPis((cAliasCD5)->CD5_DTPPIS)
oA120:setBCofImp((cAliasCD5)->CD5_BSCOF)
oA120:setVCofImp((cAliasCD5)->CD5_VLCOF)
oA120:setDtPgCof((cAliasCD5)->CD5_DTPCOF)
oA120:setLocal((cAliasCD5)->CD5_LOCAL)
//Adiciona novo registro
oA120:AddA120()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC180
@description Função para processar registros C180, C181 e C185
@param cChaveC010,String,Relação com registro pai C010
@param oC180,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC180(cChaveC010, oC180, cAliasSFT,cCodProd,cConta,cStMoto,lPISCOFP, dMVICMDSDT)

//todo 3-Recursivo
Local cChaveC180	:= ''
Local nBasePis		:= 0 //Base de Pis normal
Local nBaseCof		:= 0 //Base de COFINS normal
Local nBasePisQ		:= 0 //Base de pis em quantidade
Local nBaseCofQ		:= 0 //Base de Cofinsem quantidade
Local nAlqPisR		:= 0 //Alíquota PIS em reais
Local nAlqCofR		:= 0 //Alíquota Cofins em reais
Local lPautPis		:= .F.
Local lPautCof		:= .F.
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Local nVlPis		:= 0
Local nVlCof		:= 0
Local cEntSai 		:= Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS 		:= (cAliasSFT)->FT_VALICM
Local cDedbspc 		:= (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  		:= (cAliasSFT)->FT_TIPO
Local nValDesco 	:= DedPisCof(oC180:getDedbpis(),oC180:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)
Local cCodNcm 		:= Iif(!Empty((cAliasSFT)->FT_POSIPI), (cAliasSFT)->FT_POSIPI, (cAliasSFT)->B1_POSIPI)
Local lSTMot		:= cStMoto == '1'
Local lPISCstST		:= ((cAliasSFT)->FT_CSTPIS == '05' .AND. (cAliasSFT)->F4_PSCFST == '4')
Local lCOFCstST		:= ((cAliasSFT)->FT_CSTCOF == '05'.AND. (cAliasSFT)->F4_PSCFST == '4')
Local nDescZFR		:= Iif((cAliasSFT)->FT_TIPO <> "D", (cAliasSFT)->FT_DESCZFR, 0)
Local nValorItem	:= Iif(lSTMot, 0, (cAliasSFT)->FT_TOTAL + nDescZFR)


nVlPis		:= (cAliasSFT)->FT_VALPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
nAlqCof		:= (cAliasSFT)->FT_ALIQCOF
nBasePis	:= (cAliasSFT)->FT_BASEPIS
nBaseCof	:= (cAliasSFT)->FT_BASECOF

//Grava valores de PIS COFINS ST
If lSTMot .Or. lPISCstST
	nVlPis		:= (cAliasSFT)->FT_VALPS3
	nAlqPis		:= (cAliasSFT)->FT_ALIQPS3
	nBasePis	:= (cAliasSFT)->FT_BASEPS3
EndIf
If lSTMot .Or. lCOFCstST
	nVlCof		:= (cAliasSFT)->FT_VALCF3
	nAlqCof		:= (cAliasSFT)->FT_ALIQCF3
	nBaseCof	:= (cAliasSFT)->FT_BASECF3
Endif

oC180:setTNatRec((cAliasSFT)->FT_TNATREC)
oC180:setCNatRec((cAliasSFT)->FT_CNATREC)
oC180:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC180:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC180:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC180:setiQtde((cAliasSFT)->FT_QUANT)
oC180:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC180:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC180:getAlqReal()
	nBasePisQ	:= oC180:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC180:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC180:setiQtde((cAliasSFT)->FT_QUANT)
oC180:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC180:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC180:getAlqReal()
	nBaseCofQ	:= oC180:getBaseQtd()
	lPautCof	:= .T.
EndIF

//-------------------------------------------------------------------------------------------
//Irá verificar se a nota fiscal foi devolvida no mesmo período. Se sim irá reduzir valor
//da base de cálculo e valor da contribuição.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->CF4_VALPIS > 0 

	nBasePisQ	:= 0

	If lSTMot .Or. lPISCstST
		nVlPis		-= (cAliasSFT)->FT_VALPS3
		nBasePis	-= (cAliasSFT)->FT_BASEPS3	
	Else
		nVlPis		-= (cAliasSFT)->CF4_VALPIS
		nBasePis	-= (cAliasSFT)->CF4_BASPIS
	Endif
	
EndIF

If (cAliasSFT)->CF4_VALCOF > 0

	nBaseCofQ	:= 0
				   
	If lSTMot .Or. lCOFCstST
		nVlCof		-= (cAliasSFT)->FT_VALCF3
		nBaseCof	-= (cAliasSFT)->FT_BASECF3
	Else
		nVlCof		-= (cAliasSFT)->CF4_VALCof
		nBaseCof	-= (cAliasSFT)->CF4_BASCof 
	Endif

EndIF

 IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	nBasePis :=	nBaseCof
EndIF

cCodNcm := Iif((Empty(cCodNcm) .or. Alltrim(cCodNcm) =="99"), "00", cCodNcm) // Código NCM

//-------------------------------------------------------------------
//Passa informações para registro C180
//-------------------------------------------------------------------
oC180:setRelac(cChaveC010)
oC180:setnModelo('55')
oC180:setnDtDe(oC180:getDtDe())
oC180:setnDtAte(oC180:getDtAte())
oC180:setCodItem(cCodProd)
oC180:setNcm(cCodNcm)
oC180:setExNcm((cAliasSFT)->B1_EX_NCM)
oC180:setValItem(nValorItem)//se cStMoto == 1 não deverá ter valor de item
//processa registro C180
oC180:AddC180()

//-------------------------------------------------------------------
//Passa informações em comum para C181 e C185
//-------------------------------------------------------------------
cChaveC180	:=oC180:getGrupo()
oC180:setRelac(cChaveC180)
oC180:setiCFOP((cAliasSFT)->FT_CFOP)
oC180:setValItem(nValorItem)
oC180:setiVaDesc((cAliasSFT)->FT_DESCONT + nValDesco + nDescZFR)
oC180:setConta(cConta)

//-------------------------------------------------------------------
//Passa informações específicas para registro C181 de PIS
//-------------------------------------------------------------------
oC180:setiValPis(nVlPis)
oC180:setiBasPis(Iif(lPautPis,0,nBasePis - nDescZFR))  //Base Normal
oC180:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC180:setPautPis(nAlqPisR)//Alíquota em reais
oC180:setPisQtde(nBasePisQ) //Base em quantidade
oC180:setiCSTPis(Iif(cStMoto=='2','01',(cAliasSFT)->FT_CSTPIS)) //se cStMoto == '2' então CST deverpá ser obrigatório 01
//processa registro C181
oC180:AddC181()

//-------------------------------------------------------------------
//Passa informações específicas para registro C185 de COFINS
//-------------------------------------------------------------------
oC180:setiValCof(nVlCof)
oC180:setiBasCof(Iif(lPautCof,0,nBasePis - nDescZFR))//Base normal
oC180:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC180:setPautCof(nAlqCofR) //Alíquota em reais
oC180:setCofQtde(nBaseCofQ) //Base em quantidade
oC180:setiCSTCof(Iif(cStMoto=='2','01',(cAliasSFT)->FT_CSTCOF)) //se cStMoto == '2' então CST deverpá ser obrigatório 01
//processa registro C185
oC180:AddC185()

Return cChaveC180

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC190
@description Função para processar registros C190, C191 e C195
@param cChaveC010,String,Relação com registro pai C010
@param oC190,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC190(cChaveC010, oC190, cAliasSFT, cCodProd,cConta,lPISCOFP, dMVICMDSDT, lMistAtf)
Local cChaveC190:= ''
Local nVlPis	:= 0
Local nVlCof	:= 0
Local nAlqPis	:= 0
Local nAlqCof	:= 0
Local nBasePis	:= 0 //Base de Pis normal
Local nBaseCof	:= 0 //Base de COFINS normal
Local nBasePisQ	:= 0 //Base de pis em quantidade
Local nBaseCofQ	:= 0 //Base de Cofinsem quantidade
Local nAlqPisR	:= 0 //Alíquota PIS em reais
Local nAlqCofR	:= 0 //Alíquota Cofins em reais
Local lPautPis	:= .F.
Local lPautCof	:= .F.
Local cCnpj		:= ''
Local cEntSai 	:= Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS 	:= (cAliasSFT)->FT_VALICM
Local cDedbspc 	:= (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  	:= (cAliasSFT)->FT_TIPO
Local nValDesco := DedPisCof(oC190:getDedbpis(),oC190:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)
Local cCstPis	:= (cAliasSFT)->FT_CSTPIS
Local cCstCof	:= (cAliasSFT)->FT_CSTCOF
Local cCodNcm	:= Iif(!Empty((cAliasSFT)->FT_POSIPI), (cAliasSFT)->FT_POSIPI, (cAliasSFT)->B1_POSIPI)

nVlPis		:= (cAliasSFT)->FT_VALPIS
nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqCof		:= (cAliasSFT)->FT_ALIQCOF
nBasePis	:= (cAliasSFT)->FT_BASEPIS
nBaseCof	:= (cAliasSFT)->FT_BASECOF

oC190:setTNatRec((cAliasSFT)->FT_TNATREC)
oC190:setCNatRec((cAliasSFT)->FT_CNATREC)
oC190:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC190:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC190:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC190:setiQtde((cAliasSFT)->FT_QUANT)
oC190:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC190:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC190:getAlqReal()
	nBasePisQ	:= oC190:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC190:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC190:setiQtde((cAliasSFT)->FT_QUANT)
oC190:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC190:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC190:getAlqReal()
	nBaseCofQ	:= oC190:getBaseQtd()
	lPautCof	:= .T.
EndIF

//-------------------------------------------------------------------------------------------
//Irá verificar se a nota fiscal foi devolvida no mesmo período. Se sim irá reduzir valor
//da base de cálculo e valor da contribuição.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
	nBasePisQ	:= 0
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
	nBaseCofQ	:= 0
EndIF

IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	//Se por algum a base de cálculo de COFINS for maior que a de PIS e houve redução por conta de devolução dentro do período, significa que o percentual de devolução foi tão pequeno que o PIS não atingiu 0,01 centavo, por exemplo:
	//Devolução parcial que corresponde a 0,2% de uma nota com base de cálculo original de 100, ficaria PIS de 100 * 0,2% = Nova base de 0,2, logo 0,2 * 1,65% = 0,0033, ou seja não atingiu 1 centavo, no arquivo não será reduzido.
	//Já para a COFINS isso muda pelo fato da alíquota ser maior, ficaria 100 * 0,2% = nova base   0,2, logo 0,2 * 7,6 = 0,0152, neste caso teriamos 2 centavos, e no arquivo será reduzido.
	//O problema que é tanto o valor e base de cálculo devem ser reduzidos, então a base de PIS não será reduzida mas a de COFINS será, ficando diferentes e isso causa erro no PVA.
	//Por este motivo se a base de COFINS for menor que a de PIS, irei igualar a base, pois como o valor reduzido de PIS é menor que 1 centavo, não causará erro. Neste exemplo a base de COFINS ficou 99,80
	//99,80 * 1,65 = 1,6467, que arredondando ficaria os mesmos 1,65. 99,80 * 7,6 = 7,5848, que seá 7,58, desta forma não causará erro no PVA.
	//Se o valor a ser reduzido de PIS é insignificativo, então não terá problema de igualar a base de PIS com a de COFINS, não causará diferença do valor de PIS.
	nBasePis :=	nBaseCof
EndIF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0 .AND. !lPautPis
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0 .AND. !lPautCof
		nVlCof	-= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIf

cCodNcm := Iif(Empty(cCodNcm), "00", cCodNcm) // Código NCM

//-------------------------------------------------------------------
//Passa informações para registro C190
//-------------------------------------------------------------------
oC190:setRelac(cChaveC010)
oC190:setnModelo('55')
oC190:setnDtDe(oC190:getDtDe())
oC190:setnDtAte(oC190:getDtAte())
oC190:setCodItem(cCodProd)
oC190:setNcm(cCodNcm)
oC190:setExNcm((cAliasSFT)->B1_EX_NCM)
oC190:setValItem((cAliasSFT)->FT_TOTAL)
//processa registro C190
oC190:AddC190()

//-------------------------------------------------------------------
//Passa informações em comum para C191 e C195
//-------------------------------------------------------------------
//Verificação do CNPJ
If (cEntSai=='1' .And. !(cAliasSFT)->FT_TIPO$'BD') .or. (cEntSai=='2' .And. (cAliasSFT)->FT_TIPO$'BD')
	IF (cAliasSFT)->A2_EST	== 'EX'
		cCnpj := ""
	Else
		cCnpj := (cAliasSFT)->A2_CGC
	EndIF

Else
	IF (cAliasSFT)->A1_EST	== 'EX'
		cCnpj := ""
	Else
		cCnpj := (cAliasSFT)->A1_CGC
	EndIF
EndIF

cChaveC190	:= oC190:getGrupo()
oC190:setRelac(cChaveC190)
oC190:setiCFOP((cAliasSFT)->FT_CFOP)
oC190:setValItem((cAliasSFT)->FT_TOTAL)
oC190:setiVaDesc((cAliasSFT)->FT_DESCONT + nValDesco)
oC190:setiCnpj(cCnpj)
oC190:setConta(cConta)

//Verifica se há ativos entre os itens da nota
If (lMistAtf .And. (cAliasSFT)->(F4_ATUATF) != "N") .Or. ((cAliasSFT)->FT_TIPOMOV == 'E' .AND. ;
	cCstPis $ "98/99" .AND. ((cAliasSFT)->CF4_VALPIS > 0 .OR. (cAliasSFT)->FT_TIPO == "D"))	
	
	nVlPis		:= 0
	nBasePis	:= 0
	nVlCof		:= 0
	nBaseCof	:= 0

	If lMistAtf .And. !(cCstPis $ "70|71|72|73|74|98|99" .Or. cCstCof $ "70|71|72|73|74|98|99")
		cCstPis := "98"
		cCstCof := "98"
	EndIf	
EndIF

//-------------------------------------------------------------------
//Passa informações específicas para registro C191 de PIS
//-------------------------------------------------------------------
oC190:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
oC190:setPautPis(nAlqPisR)//Alíquota em reais
oC190:setPisQtde(nBasePisQ) //Base em quantidade
oC190:setiCSTPis(cCstPis)
oC190:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC190:setiValPis(nVlPis)
//processa registro C191
oC190:AddC191()

//-------------------------------------------------------------------
//Passa informações específicas para registro C195 de COFINS
//-------------------------------------------------------------------
oC190:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
oC190:setPautCof(nAlqCofR) //Alíquota em reais
oC190:setCofQtde(nBaseCofQ) //Base em quantidade
oC190:setiCSTCof(cCstCof)
oC190:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC190:setiValCof(nVlCof)
//processa registro C195
oC190:AddC195()

Return cChaveC190

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC380
@description Função para processar registros C380, C381 e C385
@param cChaveC010,String,Relação com registro pai C010
@param oC380,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC380(cChaveC010, oC380, cAliasSFT,cCodProd,cConta,lPISCOFP,cSituaDoc)

Local lCanc	:= .F.
Local cChaveC380	:= ''
Local nBasePisQ	:= 0 //Base de pis em quantidade
Local nBaseCofQ	:= 0 //Base de Cofinsem quantidade
Local nAlqPisR	:= 0 //Alíquota PIS em reais
Local nAlqCofR	:= 0 //Alíquota Cofins em reais
Local lPautPis	:= .F.
Local lPautCof	:= .F.
Local nAlqPis		:= 0
Local nAlqCof		:= 0

nAlqPis	:= (cAliasSFT)->FT_ALIQPIS
nAlqCof	:= (cAliasSFT)->FT_ALIQCOF

oC380:setTNatRec((cAliasSFT)->FT_TNATREC)
oC380:setCNatRec((cAliasSFT)->FT_CNATREC)
oC380:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC380:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC380:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC380:setiQtde((cAliasSFT)->FT_QUANT)
oC380:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF (cAliasSFT)->FT_CSTPIS = '03' .AND. oC380:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC380:getAlqReal()
	nBasePisQ	:= oC380:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC380:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC380:setiQtde((cAliasSFT)->FT_QUANT)
oC380:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF (cAliasSFT)->FT_CSTCOF = '03' .AND. oC380:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC380:getAlqReal()
	nBaseCofQ	:= oC380:getBaseQtd()
	lPautCof	:= .T.
EndIF

If cSituaDoc == '02'
	lCanc:= .T.
EndIF
//-------------------------------------
//Passa informações para registro C380
//-------------------------------------
oC380:setRelac(cChaveC010)
oC380:setnModelo('02')
oC380:setnDtDe(oC380:getDtDe())
oC380:setnDtAte(oC380:getDtAte())
oC380:setnNumNf(Right(AllTrim((cAliasSFT)->FT_NFISCAL),6))
oC380:setnSitDoc(cSituaDoc)

IF lCanc
	//Para operação cancelada passa valor do item zerado e valor de cancelamentto
	oC380:setValItem(0)
	oC380:setVlCanc((cAliasSFT)->FT_VALCONT)
Else
	//para operação normal passa valor do item e valor de cancelamento zerado.
	oC380:setValItem((cAliasSFT)->FT_VALCONT)
	oC380:setVlCanc(0)
EndIF

//Processar C380
oC380:AddC380()

//-------------------------------------
//Informações em comum para C181 e C185
//-------------------------------------
oC380:setValItem((cAliasSFT)->FT_TOTAL)
oC380:setCodItem(cCodProd)
oC380:setConta(cConta)
oC380:setRelac(oC380:getGrupo())

//-------------------------------------
//Passa informações para registro C381
//-------------------------------------
oC380:setiValPis((cAliasSFT)->FT_VALPIS)
oC380:setiBasPis(Iif(lPautPis,0,(cAliasSFT)->FT_BASEPIS))  //Base Normal
oC380:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC380:setPautPis(nAlqPisR)//Alíquota em reais
oC380:setPisQtde(nBasePisQ) //Base em quantidade
oC380:setiCSTPis((cAliasSFT)->FT_CSTPIS)
//Processar C381
oC380:AddC381()

//-------------------------------------
//Passa informações para registro C385
//-------------------------------------
oC380:setiValCof((cAliasSFT)->FT_VALCOF)
oC380:setiBasCof(Iif(lPautCof,0,(cAliasSFT)->FT_BASECOF))//Base normal
oC380:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC380:setPautCof(nAlqCofR) //Alíquota em reais
oC380:setCofQtde(nBaseCofQ) //Base em quantidade
oC380:setiCSTCof((cAliasSFT)->FT_CSTCOF)
//Processar C385
oC380:AddC385()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC395
@description Função para processar registros C395
@param cChaveC010,String,Relação com registro pai C010
@param oC395,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC395(cChaveC010, oC395, cAliasSFT, cCodPart,cEspecie, cEFDSerie)

Local nRet			:= 0

//--------------------------------------
//Passa informações para registro C395
//--------------------------------------
oC395:setRelac(cChaveC010)
oC395:setnModelo(cEspecie)
oC395:setCodPart(cCodPart)
oC395:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oC395:setnNumNf(Right(AllTrim((cAliasSFT)->FT_NFISCAL),6))
oC395:setEmissao((cAliasSFT)->FT_EMISSAO)
nRet	:= oC395:AddC395(.T.)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC396
@description Função para processar registros C396
@param cChaveC010,String,Relação com registro pai C395
@param oC396,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC396(cChaveC395, oC396, cAliasSFT,cCodProd,cConta,nPosPai)

//--------------------------------------
//Passa informações para registro C396
//--------------------------------------
oC396:setRelac(cChaveC395)
oC396:setCodItem(cCodProd)
oC396:setValItem((cAliasSFT)->FT_TOTAL)
oC396:setiVaDesc((cAliasSFT)->FT_DESCONT)
oC396:setiCodBcc((cAliasSFT)->FT_CODBCC)
oC396:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC396:setiBasPis((cAliasSFT)->FT_BASEPIS)
oC396:setiAlqPis((cAliasSFT)->FT_ALIQPIS)
oC396:setiValPis((cAliasSFT)->FT_VALPIS)
oC396:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC396:setiBasCof((cAliasSFT)->FT_BASECOF)
oC396:setiAlqCof((cAliasSFT)->FT_ALIQCOF)
oC396:setiValCof((cAliasSFT)->FT_VALCOF)
oC396:setConta(cConta)

//Processa registro C396
If oC396:AddC396()
	//Aqui irá totalizar os valores para gerar no registro pai C395
	oC396:setValorNf( (cAliasSFT)->FT_VALCONT)
	oC396:AddC395(.F., nPosPai) //Acumula valores no registro C395
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC400
@description Função para processar registro C400
@param cChaveC010,String,Relação com registro pai C010
@param oC400,Objeto,Objeto da classe EFDCBLOCOC
@param aPar,Array,Array com informações do C400
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC400(cChaveC010, oC400, aPar)

oC400:setRelac(cChaveC010)
oC400:setModEcf(aPar[1])
oC400:setSerEcf(aPar[2])
oC400:setNumEcf(aPar[3])
oC400:AddC400()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC405
@description Função para processar registros C405
@param cChaveC010,String,Relação com registro pai C010
@param oC405,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC405(cChaveC400, oC405, cAliasSFT, cChaveC405)

Local nVlBrtLj	:= 0

DEFAULT cChaveC405 := ""

// Valor bruto deve compor cupons cancelados e descontos conforme tratamento SPEDFISCAL e SPEDPISCOF Chamado TPY382
nVlBrtLj	:= (cAliasSFT)->FI_ISS + (cAliasSFT)->FI_VALCON + (cAliasSFT)->FI_DESC //DSERFIS1-14715 - Verificado o calculo incorreto de FI_ISS + FI_VALCON + FT_DESCONT para FI_ISS + FI_VALCON + FT_DESC. //+ (cAliasSFT)->FT_DESCONT

oC405:setRelac(cChaveC400)
oC405:setDtRedZ((cAliasSFT)->FI_DTMOVTO)
oC405:setCro((cAliasSFT)->FI_CRO)
oC405:setCrZ(StrZero(Val((cAliasSFT)->FI_NUMREDZ),Len(AllTrim((cAliasSFT)->FI_NUMREDZ))) )
oC405:setNumCont((cAliasSFT)->FI_COO)
oC405:setVlGrade((cAliasSFT)->FI_GTFINAL)
oC405:setVlCanc((cAliasSFT)->FI_CANCEL)
oC405:setVlBrut(nVlBrtLj)
//Processa registro C405
oC405:AddC405(cChaveC405)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcC481485
@description Função para processar registros C481 e C485
@param cChaveC405,String,Relação com registro pai C405
@param oC481C185,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcC481485(cChaveC405, oC481C485, cAliasSFT,cConta,cCodProd,lPISCOFP)

Local nBasePisQ	:= 0 //Base de pis em quantidade
Local nBaseCofQ	:= 0 //Base de Cofinsem quantidade
Local nAlqPisR	:= 0 //Alíquota PIS em reais
Local nAlqCofR	:= 0 //Alíquota Cofins em reais
Local lPautPis	:= .F.
Local lPautCof	:= .F.
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Local nVlPis		:= 0
Local nBasePis	:= 0
Local nVlCof		:= 0
Local nBaseCof	:= 0

nAlqPis	:= (cAliasSFT)->FT_ALIQPIS
nAlqCof	:= (cAliasSFT)->FT_ALIQCOF

nVlPis		:= (cAliasSFT)->FT_VALPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF

nBasePis		:= (cAliasSFT)->FT_BASEPIS
nBaseCof		:= (cAliasSFT)->FT_BASECOF

oC481C485:setTNatRec((cAliasSFT)->FT_TNATREC)
oC481C485:setCNatRec((cAliasSFT)->FT_CNATREC)
oC481C485:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC481C485:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC481C485:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC481C485:setiQtde((cAliasSFT)->FT_QUANT)
oC481C485:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC481C485:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC481C485:getAlqReal()
	nBasePisQ	:= oC481C485:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC481C485:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC481C485:setiQtde((cAliasSFT)->FT_QUANT)
oC481C485:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC481C485:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC481C485:getAlqReal()
	nBaseCofQ	:= oC481C485:getBaseQtd()
	lPautCof	:= .T.
EndIF

If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
EndIF

IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	nBasePis :=	nBaseCof
EndIF
//-------------------------------------
//Informações em comum para C481 e C485
//-------------------------------------
oC481C485:setValItem((cAliasSFT)->FT_TOTAL)
oC481C485:setCodItem(cCodProd)
oC481C485:setConta(cConta)
oC481C485:setRelac(cChaveC405)

//-------------------------------------
//Passa informações para registro C481
//-------------------------------------
oC481C485:setiValPis(nVlPis)
oC481C485:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
oC481C485:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC481C485:setPautPis(nAlqPisR)//Alíquota em reais
oC481C485:setPisQtde(nBasePisQ) //Base em quantidade
oC481C485:setiCSTPis((cAliasSFT)->FT_CSTPIS)
//Processar C481
oC481C485:AddC481()

//-------------------------------------
//Passa informações para registro C485
//-------------------------------------
oC481C485:setiValCof(nVlCof)
oC481C485:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
oC481C485:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC481C485:setPautCof(nAlqCofR) //Alíquota em reais
oC481C485:setCofQtde(nBaseCofQ) //Base em quantidade
oC481C485:setiCSTCof((cAliasSFT)->FT_CSTCOF)
//Processar C485
oC481C485:AddC485()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC490
@description Função para processar registros C490
@param cChaveC010,String,Relação com registro pai C010
@param oC490,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC490(cChaveC010, oC490, aPar)

oC490:setRelac(cChaveC010)
oC490:setnDtDe(aPar[1])
oC490:setnDtAte(aPar[2])
oC490:setnModelo(aPar[3])
//processa registro C490
oC490:AddC490()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcC491495
@description Função para processar registros C481 e C485
@param cChaveC405,String,Relação com registro pai C405
@param oC491C495,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcC491495(cChaveC490, oC491C495, cAliasSFT,cConta,cCodProd,lPISCOFP)

Local nBasePisQ	:= 0 //Base de pis em quantidade
Local nBaseCofQ	:= 0 //Base de Cofinsem quantidade
Local nAlqPisR	:= 0 //Alíquota PIS em reais
Local nAlqCofR	:= 0 //Alíquota Cofins em reais
Local lPautPis	:= .F.
Local lPautCof	:= .F.
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Local nVlPis		:= 0
Local nBasePis	:= 0
Local nVlCof		:= 0
Local nBaseCof	:= 0

nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
nAlqCof		:= (cAliasSFT)->FT_ALIQCOF

nVlPis			:= (cAliasSFT)->FT_VALPIS
nVlCof			:= (cAliasSFT)->FT_VALCOF

nBasePis		:= (cAliasSFT)->FT_BASEPIS
nBaseCof		:= (cAliasSFT)->FT_BASECOF

oC491C495:setTNatRec((cAliasSFT)->FT_TNATREC)
oC491C495:setCNatRec((cAliasSFT)->FT_CNATREC)
oC491C495:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC491C495:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC491C495:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC491C495:setiQtde((cAliasSFT)->FT_QUANT)
oC491C495:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC491C495:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC491C495:getAlqReal()
	nBasePisQ	:= oC491C495:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC491C495:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC491C495:setiQtde((cAliasSFT)->FT_QUANT)
oC491C495:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC491C495:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC491C495:getAlqReal()
	nBaseCofQ	:= oC491C495:getBaseQtd()
	lPautCof	:= .T.
EndIF

If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
EndIF

IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	nBasePis :=	nBaseCof
EndIF

//-------------------------------------
//Informações em comum para C491 e C495
//-------------------------------------
oC491C495:setRelac(cChaveC490)
oC491C495:setValItem((cAliasSFT)->FT_TOTAL)
oC491C495:setCodItem(cCodProd)
oC491C495:setConta(cConta)
oC491C495:setiCFOP((cAliasSFT)->FT_CFOP)

//-------------------------------------
//Passa informações para registro C491
//-------------------------------------
oC491C495:setiValPis(nVlPis)
oC491C495:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
oC491C495:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC491C495:setPautPis(nAlqPisR)//Alíquota em reais
oC491C495:setPisQtde(nBasePisQ) //Base em quantidade
oC491C495:setiCSTPis((cAliasSFT)->FT_CSTPIS)
//Processar C491
oC491C495:AddC491()

//-------------------------------------
//Passa informações para registro C495
//-------------------------------------
oC491C495:setiValCof(nVlCof)
oC491C495:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
oC491C495:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC491C495:setPautCof(nAlqCofR) //Alíquota em reais
oC491C495:setCofQtde(nBaseCofQ) //Base em quantidade
oC491C495:setiCSTCof((cAliasSFT)->FT_CSTCOF)
//Processar C495
oC491C495:AddC495()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC500
@description Função para processar registros C500
@param cChaveC010,String,Relação com registro pai C010
@param oC500,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC500(cChaveC010, oC500, cAliasSFT, cCodPart,cCodInfCom,cEspecie,cEFDSerie,cSituaDoc)

Local nRet			:= 0

oC500:setRelac(cChaveC010)
oC500:setCodPart(cCodPart)
oC500:setnModelo(cEspecie)
oC500:setnSitDoc(cSituaDoc)
oC500:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oC500:setnNumNf((cAliasSFT)->FT_NFISCAL)
oC500:setEmissao((cAliasSFT)->FT_EMISSAO)
oC500:setEntrada((cAliasSFT)->FT_ENTRADA)
oC500:setCodInfC(cCodInfCom)
oC500:setChvNfe((cAliasSFT)->FT_CHVNFE)

nRet := oC500:AddC500(.T.)	//Inclui novo C500

//Os valores não serão adicionados aqui, como são obtidos do somatório dos itens
//eles ser serão totalizados em C501 e C505.

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PrcC501505
@description Função para processar registros C501 e C505
@param cChaveC500,String,Relação com registro pai C500
@param oC501C505,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcC501505(cChaveC500, oC501C505, cAliasSFT, nPosPai,cConta)

Local nVlPis		:= 0
Local nVlCof		:= 0
Local nAlqPis		:= 0
Local nAlqCof		:= 0

nVlPis		:= (cAliasSFT)->FT_VALPIS
nAlqPis	:= (cAliasSFT)->FT_ALIQPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqCof	:= (cAliasSFT)->FT_ALIQCOF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0
		nVlCof		-= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIF
//-------------------------------------
//Informações em comum para C501 e C505
//-------------------------------------
oC501C505:setRelac(cChaveC500)
oC501C505:setValItem((cAliasSFT)->FT_TOTAL)
oC501C505:setiCodBcc((cAliasSFT)->FT_CODBCC)
oC501C505:setConta(cConta)

//-------------------------------------
//Passa informações para registro C501
//-------------------------------------
oC501C505:setiBasPis((cAliasSFT)->FT_BASEPIS)
oC501C505:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC501C505:setiAlqPis(nAlqPis)
oC501C505:setiValPis(nVlPis)
//Processar C501
oC501C505:AddC501()

//-------------------------------------
//Passa informações para registro C505
//-------------------------------------
oC501C505:setiBasCof((cAliasSFT)->FT_BASECOF)
oC501C505:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC501C505:setiAlqCof(nAlqCof)
oC501C505:setiValCof(nVlCof)
//Processar C505
oC501C505:AddC505()

//----------------------------------------------------
//Aqui passa informações para geração do registro pai
//----------------------------------------------------
oC501C505:setValorNf((cAliasSFT)->FT_VALCONT)
oC501C505:setVlIcms((cAliasSFT)->FT_VALICM)
oC501C505:setnValPis(nVlPis)
oC501C505:setnValCof(nVlCof)

oC501C505:AddC500(.F.,nPosPai)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcC600
@description Função para processar registros C600
@param cChaveC010,String,Relação com registro pai C010
@param oC600,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcC600(cChaveC010, oC600, cAliasSFT,cConta,cCodMun,cEspecie,lSPDPIS06,nValST, lEnerEle, cEFDSerie, dMVICMDSDT, cSituaDoc)

Local aRegC600		:= {}
Local cCodCons		:= ''
Local cChaveC600	:= ''
Local nConskwh		:= 0
Local nValTerc		:= 0
Local nVlDa			:= 0
Local nVlNTrib		:= 0
Local nVlForn		:= 0
Local nPosC600		:= 0
Local cEntSai 		:= Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS 		:= (cAliasSFT)->FT_VALICM
Local cDedbspc 		:= (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  		:= (cAliasSFT)->FT_TIPO
Local nValDesco 	:= DedPisCof(oC600:getDedbpis(),oC600:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)

Default nValST		:= 0
Default lEnerEle	:= .F.

If cEspecie $ '06/55' .AND. !Empty((cAliasSFT)->FU_CLASCON)
	cCodCons 	:= (cAliasSFT)->FU_CLASCON
	nConskwh 	:= (cAliasSFT)->FU_CONSTOT
	nValTerc	:= (cAliasSFT)->FU_VALTERC
Elseif cEspecie == '28' .AND. !Empty((cAliasSFT)->CD3_CLASCO)
	cCodCons 	:= (cAliasSFT)->CD3_CLASCO
	nValTerc	:= (cAliasSFT)->CD3_VLTERC
	nVlForn		:= IIF( CD3->(FieldPos("CD3_VLFORN")) > 0 , (cAliasSFT)->CD3_VLFORN, 0)
Elseif cEspecie == '29'
	If	CD4->(MsSeek (xFilial ("CD4")+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
		cCodCons 	:= CD4->CD4_CLASCO
		nValTerc	:= CD4->CD4_VLTERC
		nVlForn		:= IIF( CD4->(FieldPos("CD4_VLFORN")) > 0, CD4->CD4_VLFORN, 0)
	EndIF
EndIf

//Verifica se o documento está cancelado
If cSituaDoc $ "02#03" // 02 = Cancelado / 03 = Cancelamento de NF-e homologado fora de prazo / 04 = Uso Denegado / 05 = Inutilizacao
	cCodCons	:=	(cAliasSFT)->F3_CLASCO
EndIF

//Verificação do valor de despesa
If (cAliasSFT)->FT_DESPESA - ((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE) > 0
	nVlDa	:= (cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE)
EndIf

//Verificação do valor de srviços não-tributados pelo ICMS.
If (cAliasSFT)->(FT_OUTRICM + FT_ISENICM) > 0
	nVlNTrib := (cAliasSFT)->(FT_OUTRICM + FT_ISENICM)
EndIf

oC600:setRelac(cChaveC010)
oC600:setnModelo(cEspecie)
oC600:setCodMun(cCodMun)
oC600:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oC600:setnSitDoc(cSituaDoc)
oC600:setEmissao((cAliasSFT)->FT_EMISSAO)
oC600:setClsCon(cCodCons)
oC600:setConKwh(nConskwh)
oC600:setVlForn(nVlForn)
oC600:setVlTerc(nValTerc)
oC600:setVlNTrib(nVlNTrib)
oC600:setDespesa(nVlDa)
oC600:setValorNf((cAliasSFT)->FT_VALCONT)
oC600:setnVlDesc((cAliasSFT)->FT_DESCONT + nValDesco)
oC600:setBsIcms((cAliasSFT)->FT_BASEICM)
oC600:setVlIcms((cAliasSFT)->FT_VALICM)
oC600:setNBIcmSt(IIf(nValST==0,0,(cAliasSFT)->FT_BASERET))
oC600:setVlIcmSt(nValST)
oC600:setnValPis((cAliasSFT)->FT_VALPIS)
oC600:setnValCof((cAliasSFT)->FT_VALCOF)

// Seta a chave da nota - SFT - para ser usada para "agrupar" os quantidades (Qnt Consolidada e Qnt Cancelada) no C600
oC600:setChvAtuC600(((cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))

If oC600:cChvantc600 == oC600:cChvAtuC600
	// Devem ser preenchido os valores somente 1 vez, para evitar duplicidades caso tenha mais de 1 item na nota
	oC600:setConKwh(0)
	oC600:setVlForn(0)
	oC600:setVlTerc(0)
EndIf

If cSituaDoc $ "02#03" // Se for nota de cancelamento e outras relacionadas, zero os valores
	oC600:setConKwh(0)
	oC600:setVlForn(0)
	oC600:setVlTerc(0)
	oC600:setVlNTrib(0)
	oC600:setDespesa(0)
	oC600:setValorNf(0)
	oC600:setnVlDesc(0)
	oC600:setBsIcms(0)
	oC600:setVlIcms(0)
	oC600:setNBIcmSt(0)
	oC600:setVlIcmSt(0)
	oC600:setnValPis(0)
	oC600:setnValCof(0)
EndIf

nPosC600	:= oC600:AddC600()

If lSPDPIS06
	//Realizar get do array c600 para executar ponto de entrada
	aRegC600	:= oC600:getC600(nPosC600)
	aRegC600 	:= ExecBlock("SPDPIS06",.F.,.F.,{aRegC600,cAliasSFT})

	//Realizar set para passar informações novamente para a classe
	oC600:setC600(aRegC600,nPosC600)
EndIF

//-------------------------------------------------
//Passa informações em comum registros C601 e C605
//-------------------------------------------------
cChaveC600	:= oC600:getGrupo()
oC600:setRelac(cChaveC600)
oC600:setValItem(IIf(!cSituaDoc $ "02#03", (cAliasSFT)->FT_TOTAL, 0))
oC600:setConta(cConta)

//-------------------------------------
//Passa informações para registro C601
//-------------------------------------
oC600:setiValPis(IIf(!cSituaDoc $ "02#03", (cAliasSFT)->FT_VALPIS, 0))
oC600:setiBasPis(IIf(!cSituaDoc $ "02#03", (cAliasSFT)->FT_BASEPIS, 0))
oC600:setiAlqPis((cAliasSFT)->FT_ALIQPIS)
oC600:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC600:AddC601()

//-------------------------------------
//Passa informações para registro C605
//-------------------------------------
oC600:setiValCof(IIf(!cSituaDoc $ "02#03", (cAliasSFT)->FT_VALCOF, 0))
oC600:setiBasCof(IIf(!cSituaDoc $ "02#03", (cAliasSFT)->FT_BASECOF, 0))
oC600:setiAlqCof((cAliasSFT)->FT_ALIQCOF)
oC600:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC600:AddC605()

If lEnerEle //DSERFIS1-16182 - Valor Registro C600 Somando No Registro C100. - Reinicializo as variaveis

	oC600:setDespesa(0)
	oC600:setValorNf(0)
	oC600:setnVlDesc(0)
	oC600:setBsIcms(0)
	oC600:setVlIcms(0)
	oC600:setNBIcmSt(0)
	oC600:setVlIcmSt(0)
	oC600:setnValPis(0)
	oC600:setnValCof(0)

	oC600:setValItem(0)
	oC600:setConta("")

	//-------------------------------------
	//Passa informações para registro C601
	//-------------------------------------
	oC600:setiValPis(0)
	oC600:setiBasPis(0)
	oC600:setiAlqPis(0)
	oC600:setiCSTPis("")

	//-------------------------------------
	//Passa informações para registro C605
	//-------------------------------------
	oC600:setiValCof(0)
	oC600:setiBasCof(0)
	oC600:setiAlqCof(0)
	oC600:setiCSTCof("")
EndIf

Return cChaveC600

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC120
@description Função para processar geração do registro C120
@param cChaveC100,String,Relação com registro pai C100
@param oC120,Objeto,Objeto da classe EFDCBLOCOC
@param aPar,Array,Array com informações do registro
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC120(cChaveC100, oC120, aPar)

oC120:setRelac(cChaveC100)
oC120:setDocImp(aPar[1])
oC120:setNumImp(aPar[2])
oC120:setVPisImp(aPar[3])
oC120:setVCofImp(aPar[4])
oC120:setDrawBack(aPar[5])
//Adiciona registro C120
oC120:AddC120()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Procc199
@description Função para processar geração do registro C199
@param cChaveC190,String,Relação com registro pai C190
@param oC199,Objeto,Objeto da classe EFDCBLOCOC
@param aPar,Array,Array com informações do registro
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC199(cChaveC190, oC199, aPar)

oC199:setRelac(cChaveC190)
oC199:setDocImp(aPar[1])
oC199:setNumImp(aPar[2])
oC199:setVPisImp(aPar[3])
oC199:setVCofImp(aPar[4])
oC199:setDrawBack(aPar[5])
//Adiciona registro C199
oC199:AddC199()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC170
@description Função para processar geração do registro C170
@param cChaveC100,String,Relação com registro pai C100
@param oC170,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC170(cChaveC100, oC170	, cAliasSFT,nPosC100	  ,cConta,;
					cCodProd	,lSPDFIS03 ,cClieFor ,lMV_STFRETE,cNumItem,;
					lSPDFIS04 ,cStMoto   ,cUnid    ,nQtde       ,lMVcontZF,;
					cCodNat,lPISCOFP, nValSt, lMistAtf, dMVICMDSDT)
Local cCstIcms	 := ''
Local cCstIpi		 := ''
Local cIndMovto	 := ''
Local nValDesp	 := 0
Local nVlItem	   := 0
Local nVlPis		 := 0
Local nVlCof		 := 0
Local nAlqPis		 := 0
Local nAlqCof		 := 0
Local nBasePis	 := 0 //Base de Pis normal
Local nBaseCof	 := 0 //Base de COFINS normal
Local nBasePisQ	 := 0 //Base de pis em quantidade
Local nBaseCofQ	 := 0 //Base de Cofinsem quantidade
Local nAlqPisR	 := 0 //Alíquota PIS em reais
Local nAlqCofR	 := 0 //Alíquota Cofins em reais
Local nAliqicm   := 0 // Alíquota de ICMS
Local lPautPis	 := .F.
Local lPautCof	 := .F.
Local aCst			 := {}
Local cDesc			 := ''
Local lVlContBas := .F.
Local cEntSai 	 := Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS   := (cAliasSFT)->FT_VALICM
Local cDedbspc   := (cAliasSFT)->A2_DEDBSPC
Local cTipoNf    := (cAliasSFT)->FT_TIPO
Local dEmissao	 := (cAliasSFT)->FT_EMISSAO
Local cCstPis 	 :=	(cAliasSFT)->FT_CSTPIS
Local cCstCof 	 :=	(cAliasSFT)->FT_CSTCOF

Local nValDesco  := DedPisCof(oC170:getDedbpis(),oC170:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf,dEmissao, dMVICMDSDT)

Default lMVcontZF := SuperGetMv( "MV_CONTZF" , .F. , .F. ,  )
Default cCodNat   := ''
Default nValSt	  := 0	


IF lMVcontZF .And. (cAliasSFT)->FT_DESCZFR > 0 .And. (cAliasSFT)->FT_ALIQCOF == 0 .And. (cAliasSFT)->FT_ALIQPIS == 0 .And. (cAliasSFT)->FT_TIPOMOV == "S"
	lVlContBas	:= .T.
EndIf

nVlPis	 := (cAliasSFT)->FT_VALPIS
nAlqPis	 := (cAliasSFT)->FT_ALIQPIS
nBasePis := Iif(lVlContBas,(cAliasSFT)->FT_VALCONT,(cAliasSFT)->FT_BASEPIS)
nVlCof   := (cAliasSFT)->FT_VALCOF
nAlqCof	 := (cAliasSFT)->FT_ALIQCOF
nBaseCof := Iif(lVlContBas,(cAliasSFT)->FT_VALCONT,(cAliasSFT)->FT_BASECOF)

oC170:setTNatRec((cAliasSFT)->FT_TNATREC)
oC170:setCNatRec((cAliasSFT)->FT_CNATREC)
oC170:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC170:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC170:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC170:setiQtde((cAliasSFT)->FT_QUANT)
oC170:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC170:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC170:getAlqReal()
	nBasePisQ	:= oC170:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC170:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC170:setiQtde((cAliasSFT)->FT_QUANT)
oC170:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC170:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC170:getAlqReal()
	nBaseCofQ	:= oC170:getBaseQtd()
	lPautCof	:= .T.
EndIF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0 .AND. !lPautPis
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0 .AND. !lPautCof
		nVlCof  -= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIF

//-------------------------------------------------------------------------------------------
//Irá verificar se a nota fiscal foi devolvida no mesmo período. Se sim irá reduzir valor
//da base de cálculo e valor da contribuição.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
	nBasePisQ	:= 0
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
	nBaseCofQ	:= 0
EndIF

 IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	//Se por algum a base de cálculo de COFINS for maior que a de PIS e houve redução por conta de devolução dentro do período, significa que o percentual de devolução foi tão pequeno que o PIS não atingiu 0,01 centavo, por exemplo:
	//Devolução parcial que corresponde a 0,2% de uma nota com base de cálculo original de 100, ficaria PIS de 100 * 0,2% = Nova base de 0,2, logo 0,2 * 1,65% = 0,0033, ou seja não atingiu 1 centavo, no arquivo não será reduzido.
	//Já para a COFINS isso muda pelo fato da alíquota ser maior, ficaria 100 * 0,2% = nova base   0,2, logo 0,2 * 7,6 = 0,0152, neste caso teriamos 2 centavos, e no arquivo será reduzido.
	//O problema que é tanto o valor e base de cálculo devem ser reduzidos, então a base de PIS não será reduzida mas a de COFINS será, ficando diferentes e isso causa erro no PVA.
	//Por este motivo se a base de COFINS for menor que a de PIS, irei igualar a base, pois como o valor reduzido de PIS é menor que 1 centavo, não causará erro. Neste exemplo a base de COFINS ficou 99,80
	//99,80 * 1,65 = 1,6467, que arredondando ficaria os mesmos 1,65. 99,80 * 7,6 = 7,5848, que seá 7,58, desta forma não causará erro no PVA.
	//Se o valor a ser reduzido de PIS é insignificativo, então não terá problema de igualar a base de PIS com a de COFINS, não causará diferença do valor de PIS.
	nBasePis :=	nBaseCof
EndIF

//Tratamento do CST de ICMS e de IPI
cCstIpi	 := (cAliasSFT)->FT_CTIPI
cCstIcms := (cAliasSFT)->FT_CLASFIS

//Situacao Tributaria ICMS
//Processa ponto de entrada para alterar o CST de ICMS e de IPI.
IF lSPDFIS03
	aCst :=  ExecBlock("SPDFIS03", .F., .F., {(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
	If Len(aCst)>0
		cCstIcms	:= aCst[1]
		cCstIpi	:= aCst[2]
	EndIF

	If lMV_STFRETE
		If (cAliasSFT)->FT_TIPO$'C'
	    	cCstIcms:= '0'+ SubStr((cAliasSFT)->FT_CLASFIS,2,3)
	  	EndIf
	EndIF

Else
	If Empty((cAliasSFT)->FT_CLASFIS) .Or. Len(Alltrim((cAliasSFT)->FT_CLASFIS))<>3
		If Empty((cAliasSFT)->B1_ORIGEM)
			If Empty((cAliasSFT)->B1_IMPORT) .Or. (cAliasSFT)->B1_IMPORT=='N'
				cCstIcms := '0'
			Else
				If Iif(cClieFor == 'SA1',(cAliasSFT)->A1_EST ,(cAliasSFT)->A2_EST) == 'EX'
					cCstIcms := '1'
				Else
					cCstIcms := '2'
				EndIf
			EndIf
		Else
			cCstIcms := (cAliasSFT)->B1_ORIGEM
		EndIf

		cCstIcms	+=	(cAliasSFT)->F4_SITTRIB
	EndIf

EndIF

//Descrição complementar do item
cDesc	:= (cAliasSFT)->B1_DESC
IF lSPDFIS04
	cDesc := ExecBlock("SPDFIS04", .F., .F., {(cAliasSFT)->FT_FILIAL,;
						(cAliasSFT)->FT_TIPOMOV,;
						(cAliasSFT)->FT_SERIE,;
						(cAliasSFT)->FT_NFISCAL,;
						(cAliasSFT)->FT_CLIEFOR,;
						(cAliasSFT)->FT_LOJA,;
						(cAliasSFT)->FT_ITEM,;
						(cAliasSFT)->FT_PRODUTO})
EndIF

If ((cAliasSFT)->FT_TIPO$"IPC")
	cIndMovto := '1'
Else
	cIndMovto := Iif( (cAliasSFT)->F4_ESTOQUE=="N" .and. ((cAliasSFT)->F4_MOVFIS=="N" .or. Empty((cAliasSFT)->F4_MOVFIS)),'1','0')
EndIf

//Na geração do registro C170, existe regra de que quantidade não pode ser zerada. Para documento de complemento
//deverá colocar quantidade igual a 1.
IF nQtde == 0
	nQtde := 1
EndIF

nAliqicm := (cAliasSFT)->FT_ALIQICM

//Para complemento de ICMS a quantidade não deverá ser informada.
//IF !(cAliasSFT)->FT_TIPO == "I"
	oC170:setiQtde(nQtde)
//EndIF

If ((cAliasSFT)->FT_TIPOMOV == 'E' .AND. cCstPis $ "98/99" .AND. ((cAliasSFT)->CF4_VALPIS > 0 .OR. (cAliasSFT)->FT_TIPO == "D")) .OR. ;
	(lMistAtf .And. (cAliasSFT)->(F4_ATUATF) != "N")
	
	nVlPis		:= 0
	nBasePis	:= 0
	nVlCof		:= 0
	nBaseCof	:= 0

	If lMistAtf .And. !(cCstPis $ "70|71|72|73|74|98|99" .Or. cCstCof $ "70|71|72|73|74|98|99")
		cCstPis := "98"
		cCstCof := "98"
	EndIf	
EndIF

/*
Nos registros de entrada, os valores de ICMS/ST e IPI destacados nos documentos fiscais, quando o informante não tem direito ao crédito, devem ser incorporados ao valor das mercadorias?

Os valores do ICMS/ST e/ou IPI destacados devem ser adicionados ao valor das mercadorias que é informado no campo 16 – “VL_MERC” do registro C100,
bem como no campo 07 – “VL_ITEM” do registro C170, uma vez que compõem o custo das mercadorias.
Como o informante não tem direito à apropriação do crédito, os campos “VL_ICMS_ST” e/ou “VL_IPI” dos registros C100, C170 e C190 não devem ser informados.
*/
nVlItem := (cAliasSFT)->FT_TOTAL + Iif((cAliasSFT)->FT_TIPO <> "D",(cAliasSFT)->FT_DESCZFR ,0)
If (cAliasSFT)->FT_TIPOMOV == "E" .And. (!(cAliasSFT)->F4_LFIPI$"T" .Or. (cAliasSFT)->FT_CREDST $ "3|4" ) .And. !(cAliasSFT)->FT_TIPO$"DB"
	If (cAliasSFT)->FT_CREDST $ "3|4".And. !(cAliasSFT)->FT_ANTICMS == "1"
		nVlItem += (cAliasSFT)->D1_ICMSRET
	Endif
	If !(cAliasSFT)->F4_LFIPI $ "T"
		nVlItem += (cAliasSFT)->D1_VALIPI
	Endif
EndIf

oC170:setRelac(cChaveC100)
oC170:setNumitem(cNumItem)
oC170:setCodItem(cCodProd)
oC170:setDescri(cDesc)
oC170:setUnMed(cUnid)
oC170:setValItem(Iif(cStMoto == '1',0,nVlItem))//não deverá gerar valor de item quando cStMoto for igual a 1
oC170:setiVaDesc((cAliasSFT)->FT_DESCONT + iif(oC170:getDedbpis() $ "S,I" .and. oC170:getDedbcof() $ "S,I",0,nValDesco))
oC170:setIndMvto(cIndMovto)
oC170:setCSTICMS(cCstIcms)
oC170:setiCFOP((cAliasSFT)->FT_CFOP)
oC170:setNatOper(cCodNat)
oC170:setBasIcms((cAliasSFT)->FT_BASEICM)
oC170:setAlqIcms(nAliqicm)
oC170:setICMSDC((cAliasSFT)->FT_VALICM)
oC170:setBsIcmSt(IIf(nValST==0,0,(cAliasSFT)->FT_BASERET))
oC170:setAlqcmSt(IIf(nValST==0,0,(cAliasSFT)->FT_ALIQSOL))
oC170:setICMSST(nValST)
oC170:setIndIpi('0')
oC170:setCstIpi(cCstIpi)
oC170:setEnqIpi('')
oC170:setBasIpi((cAliasSFT)->FT_BASEIPI)
oC170:setAlqIpi((cAliasSFT)->FT_ALIQIPI)
oC170:setIpiDC((cAliasSFT)->FT_VALIPI)
oC170:setiCSTPis(Iif(cStMoto=='2','01',cCstPis))//Se cStMoto == 2 então o CST deverá ser obrigatoriaente 01
oC170:setiCSTCof(Iif(cStMoto=='2','01',cCstCof))//Se cStMoto == 2 então o CST deverá ser obrigatoriaente 01
//Tratamente para CST 05(Sbustituição Tributária)
If cCstPis == '05' .And. Empty(cStMoto)
	oC170:setiBasPis(Iif(lVlContBas,(cAliasSFT)->FT_VALCONT,(cAliasSFT)->FT_BASEPS3))  //Base ST
	oC170:setiAlqPis((cAliasSFT)->FT_ALIQPS3) //Alíquota ST
	oC170:setiValPis((cAliasSFT)->FT_VALPS3) //Valor ST
Else
	oC170:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
	oC170:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
	oC170:setiValPis(nVlPis) //Valor Normal
Endif
If cCstCof == '05' .And. Empty(cStMoto)
	oC170:setiBasCof(Iif(lVlContBas,(cAliasSFT)->FT_VALCONT,(cAliasSFT)->FT_BASECF3))//Base ST
	oC170:setiAlqCof((cAliasSFT)->FT_ALIQCF3) //Alíoquota ST
	oC170:setiValCof((cAliasSFT)->FT_VALCF3) //Valor ST
Else
	oC170:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
	oC170:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota Normal
	oC170:setiValCof(nVlCof) //Valor Normal
Endif
oC170:setPisQtde(nBasePisQ) //Base em quantidade
oC170:setCofQtde(nBaseCofQ) //Base em quantidade
oC170:setPautPis(nAlqPisR)//Alíquota em reais
oC170:setPautCof(nAlqCofR) //Alíquota em reais
oC170:setConta(cConta)

//Adiciona registro C170
//Tratamento para item de moto
If cStMoto == '1'
	oC170:setiValPis((cAliasSFT)->FT_VALPS3  - (cAliasSFT)->CF4_VALPIS)
	oC170:setiValCof((cAliasSFT)->FT_VALCF3  - (cAliasSFT)->CF4_VALCOF)
	oC170:setiBasPis((cAliasSFT)->FT_BASEPS3 - (cAliasSFT)->CF4_BASPIS)  //Base Normal
	oC170:setiBasCof((cAliasSFT)->FT_BASECF3 - (cAliasSFT)->CF4_BASCOF)  //Base normal
	oC170:setiAlqPis((cAliasSFT)->FT_ALIQPS3) //Alíquota Normal
	oC170:setiAlqCof((cAliasSFT)->FT_ALIQCF3) //Alíoquotanormal

	oC170:AddC170()

	oC170:setiValPis(nVlPis)
	oC170:setiValCof(nVlCof)
	oC170:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
	oC170:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
	oC170:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
	oC170:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquotanormal

Else
	oC170:AddC170()
Endif

IF cStMoto <> '2' //Se cStMoto == 2 não deverá atualizar C100, pois já foi atualizado no primeiro item com CST 05 de ST de moto
	//-------------------------------------------------------------------
	//Aqui irá acumular os valores para geração do registro pai C100
	//-------------------------------------------------------------------
	If (cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE) > 0
		nValDesp	:=	(cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE)
	EndIf
	oC170:setValorNf((cAliasSFT)->FT_VALCONT)
	oC170:setnVlDesc((cAliasSFT)->FT_DESCONT)
	oC170:setAbatim((cAliasSFT)->FT_DESCICM+(cAliasSFT)->FT_DESCZFR + iif(oC170:getDedbpis() $ "S,I" .and. oC170:getDedbcof() $ "S,I",0,nValDesco))
	oC170:setVlMerc(nVlItem)
	oC170:setVlFrete((cAliasSFT)->FT_FRETE)
	oC170:setSeguro((cAliasSFT)->FT_SEGURO)
	oC170:setDespesa(nValDesp)
	oC170:setBsIcms((cAliasSFT)->FT_BASEICM)
	oC170:setVlIcms((cAliasSFT)->FT_VALICM)
	oC170:setNBIcmSt(IIf(nValST==0,0,(cAliasSFT)->FT_BASERET))
	oC170:setVlIcmSt(nValST)

	oC170:setIPI((cAliasSFT)->FT_VALIPI)
	oC170:setnValPis(nVlPis)
	oC170:setnValCof(nVlCof)
	oC170:setPisSt((cAliasSFT)->FT_VALPS3)
	oC170:setCofSt((cAliasSFT)->FT_VALCF3)
	//Somente acumula valores em C100, não adiciona novo C00
	oC170:AddC100(.F.,nPosC100)
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC175
@description Função para processar geração do registro C175
@param cChaveC100,String,Relação com registro pai C100
@param oC175,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC175(cChaveC100, oC175, cAliasSFT,nPosC100,cConta,lPISCOFP, dMVICMDSDT)

Local nValDesp	:= 0
Local nValSt	:= 0 //todo
Local nBasePis	:= 0 //Base de Pis normal
Local nBaseCof	:= 0 //Base de COFINS normal
Local nBasePisQ	:= 0 //Base de pis em quantidade
Local nBaseCofQ	:= 0 //Base de Cofinsem quantidade
Local nAlqPisR	:= 0 //Alíquota PIS em reais
Local nAlqCofR	:= 0 //Alíquota Cofins em reais
Local lPautPis	:= .F.
Local lPautCof	:= .F.
Local nAlqPis	:= 0
Local nAlqCof	:= 0
Local nVlPis	:= 0
Local nVlCof	:= 0
Local cEntSai   := Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS  := (cAliasSFT)->FT_VALICM
Local cDedbspc  := (cAliasSFT)->A2_DEDBSPC
Local cTipoNf   := (cAliasSFT)->FT_TIPO
Local nValDesco := DedPisCof(oC175:getDedbpis(),oC175:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)

nVlPis		:= (cAliasSFT)->FT_VALPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqPis	    := (cAliasSFT)->FT_ALIQPIS
nAlqCof   	:= (cAliasSFT)->FT_ALIQCOF
nBasePis	:= (cAliasSFT)->FT_BASEPIS
nBaseCof	:= (cAliasSFT)->FT_BASECOF

If (cAliasSFT)->FT_CSTPIS == '05' .AND. (cAliasSFT)->F4_PSCFST == '4'
	nVlPis		:= (cAliasSFT)->FT_VALPS3
	nAlqPis		:= (cAliasSFT)->FT_ALIQPS3
	nBasePis	:= (cAliasSFT)->FT_BASEPS3
EndIf
If (cAliasSFT)->FT_CSTCOF == '05' .AND. (cAliasSFT)->F4_PSCFST == '4'
    nVlCof		:= (cAliasSFT)->FT_VALCF3
	nAlqCof		:= (cAliasSFT)->FT_ALIQCF3
	nBaseCof	:= (cAliasSFT)->FT_BASECF3
Endif

oC175:setTNatRec((cAliasSFT)->FT_TNATREC)
oC175:setCNatRec((cAliasSFT)->FT_CNATREC)
oC175:setGNatRec((cAliasSFT)->FT_GRUPONC)
oC175:setDNatRec((cAliasSFT)->FT_DTFIMNT)

//Faz conversão de valores de pauta de PIS
oC175:setVlPauta((cAliasSFT)->FT_PAUTPIS )
oC175:setiQtde((cAliasSFT)->FT_QUANT)
oC175:setiBsPaut((cAliasSFT)->FT_BASEPIS)
IF oC175:OperPauta(PIS,lPISCOFP)
	nAlqPisR	:= oC175:getAlqReal()
	nBasePisQ	:= oC175:getBaseQtd()
	lPautPis	:= .T.
EndIF

//Faz conversão de valores de pauta de COFINS
oC175:setVlPauta((cAliasSFT)->FT_PAUTCOF)
oC175:setiQtde((cAliasSFT)->FT_QUANT)
oC175:setiBsPaut((cAliasSFT)->FT_BASECOF)
IF oC175:OperPauta(COFINS,lPISCOFP)
	nAlqCofR	:= oC175:getAlqReal()
	nBaseCofQ	:= oC175:getBaseQtd()
	lPautCof	:= .T.
EndIF

//-------------------------------------------------------------------------------------------
//Irá verificar se a nota fiscal foi devolvida no mesmo período. Se sim irá reduzir valor
//da base de cálculo e valor da contribuição.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
	nBasePisQ	:= 0
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
	nBaseCofQ	:= 0
EndIF

IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	nBasePis :=	nBaseCof
EndIF

oC175:setRelac(cChaveC100)
oC175:setiCFOP((cAliasSFT)->FT_CFOP)
oC175:setValItem((cAliasSFT)->FT_TOTAL + Iif((cAliasSFT)->FT_TIPO <> "D",(cAliasSFT)->FT_DESCZFR ,0))
oC175:setiVaDesc((cAliasSFT)->FT_DESCONT + nValDesco)
oC175:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC175:setiBasPis(Iif(lPautPis,0,nBasePis))  //Base Normal
oC175:setiAlqPis(Iif(lPautPis,0,nAlqPis)) //Alíquota Normal
oC175:setPisQtde(nBasePisQ) //Base em quantidade
oC175:setPautPis(nAlqPisR)//Alíquota em reais
oC175:setiValPis(nVlPis)
oC175:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC175:setiBasCof(Iif(lPautCof,0,nBaseCof))//Base normal
oC175:setiAlqCof(Iif(lPautCof,0,nAlqCof)) //Alíoquota normal
oC175:setCofQtde(nBaseCofQ) //Base em quantidade
oC175:setPautCof(nAlqCofR) //Alíquota em reais
oC175:setiValCof(nVlCof)
oC175:setConta(cConta)
oC175:setInfComp('')
//Adiciona registro C175
oC175:AddC175()

//Aqui irá acumular os valores para geração do registro pai C100
nValDesp	:=	Max((cAliasSFT)->FT_DESPESA - ((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE), 0)

oC175:setValorNf((cAliasSFT)->FT_VALCONT)
oC175:setnVlDesc((cAliasSFT)->FT_DESCONT)
oC175:setAbatim((cAliasSFT)->FT_DESCICM+(cAliasSFT)->FT_DESCZFR + iif(oC175:getDedbpis() $ "S,I" .and. oC175:getDedbcof() $ "S,I",0,nValDesco))
oC175:setVlMerc((cAliasSFT)->FT_TOTAL + Iif((cAliasSFT)->FT_TIPO <> "D",(cAliasSFT)->FT_DESCZFR ,0))
oC175:setVlFrete((cAliasSFT)->FT_FRETE)
oC175:setSeguro((cAliasSFT)->FT_SEGURO)
oC175:setDespesa(nValDesp)
oC175:setBsIcms((cAliasSFT)->FT_BASEICM)
oC175:setVlIcms((cAliasSFT)->FT_VALICM)
oC175:setNBIcmSt((cAliasSFT)->FT_BASERET)
oC175:setVlIcmSt(nValSt)
oC175:setIPI((cAliasSFT)->FT_VALIPI)
oC175:setnValPis(nVlPiS)
oC175:setnValCof(nVlCof)
oC175:setPisSt((cAliasSFT)->FT_VALPS3)
oC175:setCofSt((cAliasSFT)->FT_VALCF3)
oC175:AddC100(.F.,nPosC100)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC100
@description Função para processar geração do registro C100
@param cChaveC010,String,Relação com registro pai C010
@param oC100,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 12/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC100(cChaveC010, oC100, cAliasSFT,cCodPart,cIndPagto,cEspecie,lSPDPIS08,cFrete,lSPDPIS05,lMVCF3ENTR,lSitDocCDT,cSitExt,cEFDSerie,lMT)

Local cSituaDoc	:= ''
Local cIndEmi		:= ''
Local cIndOper	:= ''
local cChave		:= ''
Local nRet			:= 0
Local aCmpAntSFT	:= {}
Local aSpedC100	:= {}
Local dDtEntrada

//Aqui chama função do SPEDXFUN para verificar situação do documento
cSituaDoc		:=	SPEDSitDoc (, cAliasSFT,,,oC100:getDtDe(),oC100:getDtAte(),,lSitDocCDT,cSitExt,,,.T.)

//Trata indicador de movimento, entrada =1, saída =2
cIndOper	:=	Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")

//Chama função para definir indicador de emissão do documento
cIndEmi:=IndEmit((cAliasSFT)->FT_FORMUL, cIndOper)

//Define data de entrada...lembrando que para documento de saída irá considerar conforme o parâmetro MVCF3ENTR
dDtEntrada :=Iif((cIndOper=="2" .And. lMVCF3ENTR) .Or. cIndOper=="1",(cAliasSFT)->FT_ENTRADA,CToD("  /  /  "))

//Ponto de entrada para processar campo 11 do c100, data de entrada saída
If lSPDPIS08
	cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
	dDtEntrada := ExecBlock("SPDPIS08", .F., .F., {"SFT", cChave})
EndIF

//³Ponto de entrada para o campo 13(IND_PAGTO)
If lSPDPIS05
	aCmpAntSFT		:={	(cAliasSFT)->FT_NFISCAL,;
					(cAliasSFT)->FT_SERIE,;
					(cAliasSFT)->FT_CLIEFOR,;
					(cAliasSFT)->FT_LOJA,;
					Iif((cIndOper=="2" .And. lMVCF3ENTR) .Or.cIndOper=="1",(cAliasSFT)->FT_ENTRADA,CToD("  /  /  ")),;		//05
					(cAliasSFT)->FT_EMISSAO,;
					(cAliasSFT)->FT_DTCANC,;
					(cAliasSFT)->FT_FORMUL,;
					(cAliasSFT)->FT_CFOP}

   	aSpedC100 := ExecBlock("SPDPIS05", .F., .F., {"SFT",aCmpAntSFT,0,cIndPagto,cFrete})
	cIndPagto := aSpedC100[01]
	cFrete	   := aSpedc100[02]

Endif

oC100:setRelac(cChaveC010)
oC100:setIndOper(Iif(cIndOper== '1'  ,'0'  ,'1'  ))
oC100:setIndEmit(cIndEmi)
oC100:setCodPart(cCodPart)
oC100:setnModelo(cEspecie)
oC100:setnSitDoc(cSituaDoc)
oC100:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie,cEFDSerie))
oC100:setnNumNf((cAliasSFT)->FT_NFISCAL)
oC100:setChvNfe(Iif (!cSituaDoc$"05",(cAliasSFT)->FT_CHVNFE ,'' ) )
oC100:setEmissao((cAliasSFT)->FT_EMISSAO)
oC100:setEntrada(dDtEntrada)
oC100:setIndPgto(cIndPagto)
oC100:setTpFrt(cFrete)
nRet	:= oC100:AddC100(.T.,,lMT)

//Os demais valores do registro C100 são obtidos com a soma dos valores por item
//por este motivo os valores serão obitodos através do processamento dos itens.

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD100
@description Função para processar as informações do registro D100
@param cChaveD010,String,Relação com registro pai D010
@param oD100,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
 Function ProcD100(cChaveD010, oD100, cAliasSFT,cCodPart,cConta,cOpSemF,cEspecie, cEFDSerie, cCodRSef,cSituaDoc)

Local cIndFrt		:= ''
Local cIndEmi		:= ''
Local cChvCte		:= ''
Local cDoctms		:= ''
Local cIndOper	:= ''
Local cCodInfCom	:= ''
Local nRet			:= 0
Local cFrete		:= ''

Default cCodRSef	:= ''

cIndOper	:=	IndMovto((cAliasSFT)->FT_TIPOMOV)
//Chama função para definir indicador de emissão do documento
cIndEmi:=IndEmit((cAliasSFT)->FT_FORMUL, cIndOper)

If cEspecie $ "57/67"
    cChvCte := (cAliasSFT)->FT_CHVNFE
EndIf

//Não verifica aqui integração com TMS, pois aqui sempre será documento de entrada.
Do Case
   Case (cAliasSFT)->F1_TPCTE=="N"
     	cDoctms := "0" //- CT-e Normal
   Case (cAliasSFT)->F1_TPCTE=="C"
    	cDoctms := "1" //- CT-e de Complemento de Valores
   Case (cAliasSFT)->F1_TPCTE=="A"
    	cDoctms := "2" //- CT-e de Anulação de Valores
   Case (cAliasSFT)->F1_TPCTE=="S"
    	cDoctms := "3" //- CT-e Substituto
EndCase

If !Empty(cOpSemF) .And. AllTrim((cAliasSFT)->FT_CFOP)$cOpSemF
	cFrete	:= "9"
Else
	cFrete	:=  SPEDSitFrt(cAliasSFT,'',.T.,'','F1_FRETE',.T.,.T.,.T.)
EndIf

If Len(cFrete) > 0 .And.  AllTrim(cFrete) <> "9"
	cIndFrt	:= IIf (cSituaDoc$"02#03", "", If(AllTrim(cFrete)$"3/4","1",cFrete))

ElseIf AllTrim((cAliasSFT)->FT_CFOP)$cOpSemF .OR. cFrete=="9"
	cIndFrt := IIf (cSituaDoc$"02#03", "", "9")

ElseIf ((cAliasSFT)->F1_FRETE)>0
	 cIndFrt:=  IIf (cSituaDoc$"02#03", "", "0")

ElseIf Len((cAliasSFT)->FT_OBSERV)>0 .And.  AllTrim((cAliasSFT)->FT_OBSERV)== "CONHEC. FRETE" 	//17 - IND_FRT
	cIndFrt	:=  IIf (cSituaDoc$"02#03", "", "2")

Else
	cIndFrt	:=  IIf (cSituaDoc$"02#03", "", "1")

EndIf

oD100:setRelac(cChaveD010)
oD100:setIndEmit(cIndEmi)
oD100:setCodPart(cCodPart)
oD100:setnModelo(cEspecie)
oD100:setnSitDoc(cSituaDoc)
oD100:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oD100:setnNumNf((cAliasSFT)->FT_NFISCAL)
oD100:setChvCte(cChvCte)
oD100:setEmissao((cAliasSFT)->FT_EMISSAO)
oD100:setDtAqui((cAliasSFT)->FT_ENTRADA)
oD100:setTpCt(cDoctms)
oD100:setIndFrt(cIndFrt)
oD100:setnInfCmp(cCodInfCom)
oD100:setConta(cConta)

nRet	:= oD100:AddD100(.T.)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcD101105
@description Função para processar as informações do registros D101 e D105
@param cChaveD010,String,Relação com registro pai D100
@param oD105D105,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcD101105(cChaveD100, oD105D105, cAliasSFT, nPosPai,cConta,lMistAtf)

Local 	nValNT	:= 0

Local nVlPis		:= 0
Local nVlCof		:= 0
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Local nBasePis		:= 0
Local nBaseCof		:= 0
Local cCstPis		:= (cAliasSFT)->FT_CSTPIS
Local cCstCof		:= (cAliasSFT)->FT_CSTCOF
Local cCodBcc		:= (cAliasSFT)->FT_CODBCC

nVlPis		:= (cAliasSFT)->FT_VALPIS
nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqCof		:= (cAliasSFT)->FT_ALIQCOF
nBasePis	:= (cAliasSFT)->FT_BASEPIS
nBaseCof	:= (cAliasSFT)->FT_BASECOF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0
		nVlCof		-= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIF

If ((cAliasSFT)->FT_TIPOMOV == 'E' .AND. cCstPis $ "98/99" .AND. ((cAliasSFT)->CF4_VALPIS > 0 .OR. (cAliasSFT)->FT_TIPO == "D")) .OR. ;
	(lMistAtf .And. (cAliasSFT)->(F4_ATUATF) != "N")
	
	nVlPis		:= 0
	nBasePis	:= 0
	nVlCof		:= 0
	nBaseCof	:= 0

	If lMistAtf .And. !(cCstPis $ "70|71|72|73|74|98|99" .Or. cCstCof $ "70|71|72|73|74|98|99")
		cCstPis := "98"
		cCstCof := "98"
		cCodBcc := "14" //Precisa ser 14 (Aquisição de serviço de transporte subcontratação), por que o código que vem da TES, é do ativo não valida o arquivo.
	EndIf	
EndIF

//-------------------------------------------
//Passa informações em comum para D101 e D105
//-------------------------------------------
oD105D105:setRelac(cChaveD100)
oD105D105:setINFrt((cAliasSFT)->FT_INDNTFR)
oD105D105:setValItem((cAliasSFT)->FT_TOTAL)
oD105D105:setiCodBcc(cCodBcc)
oD105D105:setConta(cConta)

//-------------------------------------
//Passa informações para registro D101
//-------------------------------------
oD105D105:setiBasPis(nBasePis)
oD105D105:setiAlqPis(nAlqPis)
oD105D105:setiValPis(nVlPis)
oD105D105:setiCSTPis(cCstPis)
oD105D105:AddD101()

//-------------------------------------
//Passa informações para registro D105
//-------------------------------------

oD105D105:setiBasCof(nBaseCof)
oD105D105:setiCSTCof(cCstCof)
oD105D105:setiAlqCof(nAlqCof)
oD105D105:setiValCof(nVlCof)
oD105D105:AddD105()

//Aqui irá acumular valores para completar geração do registro Pai D100
//Totaliza valor não tributado
nValNT	:= (cAliasSFT)->FT_OUTRICM+(cAliasSFT)->FT_OUTRRET+(cAliasSFT)->FT_ISENICM+(cAliasSFT)->FT_ISENRET
oD105D105:setValorNf((cAliasSFT)->FT_VALCONT)
oD105D105:setnVlDesc((cAliasSFT)->FT_DESCONT)
oD105D105:setVlServ((cAliasSFT)->FT_VALCONT)
oD105D105:setBasIcms((cAliasSFT)->FT_BASEICM)
oD105D105:setValIcms((cAliasSFT)->FT_VALICM)
oD105D105:setVlNTrib(nValNT)

oD105D105:AddD100(.F.,nPosPai) //Acumula valores em D00

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD200
@description Função para processar as informações do registro D200
@param cChaveD010,String,Relação com registro pai D010
@param oD200,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.  
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcD200(cChaveD010, oD200, cAliasSFT,cConta,cEspecie, cEFDSerie, cCodRSef,cSituaDoc)

Local ChaveD200	:= ''

Default cCodRSef := ''

oD200:setRelac(cChaveD010)
oD200:setnModelo(cEspecie)
oD200:setnSitDoc(cSituaDoc)
oD200:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oD200:setnNumNf((cAliasSFT)->FT_NFISCAL)
oD200:setiCFOP((cAliasSFT)->FT_CFOP)
oD200:setEmissao((cAliasSFT)->FT_EMISSAO)
oD200:setValorNf((cAliasSFT)->FT_VALCONT)
oD200:setnVlDesc((cAliasSFT)->FT_DESCONT)
oD200:AddD200()

//-------------------------------------------
//Passa informações em comum para D201 e D205
//-------------------------------------------
ChaveD200	:= oD200:getGrupo()
oD200:setRelac(ChaveD200)
oD200:setValItem((cAliasSFT)->FT_VALCONT)
oD200:setConta(cConta)

//-------------------------------------
//Passa informações para registro D201
//-------------------------------------
oD200:setiValPis((cAliasSFT)->FT_VALPIS)
oD200:setiBasPis((cAliasSFT)->FT_BASEPIS)
oD200:setiAlqPis((cAliasSFT)->FT_ALIQPIS)
oD200:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oD200:AddD201()

//-------------------------------------
//Passa informações para registro D205
//-------------------------------------
oD200:setiValCof((cAliasSFT)->FT_VALCOF)
oD200:setiBasCof((cAliasSFT)->FT_BASECOF)
oD200:setiAlqCof((cAliasSFT)->FT_ALIQCOF)
oD200:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oD200:AddD205()


Return ChaveD200


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD300
@description Função para processar as informações do registro D300
@param cChaveD010,String,Relação com registro pai D010
@param oD300,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcD300(cChaveD010, oD300, cAliasSFT,cConta,cEspecie, cEFDSerie, dMVICMDSDT)

Local cChaveD300	:= ''
Local cEntSai := Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS := (cAliasSFT)->FT_VALICM
Local cDedbspc := (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  := (cAliasSFT)->FT_TIPO
Local nValDesco := DedPisCof(oD300:getDedbpis(),oD300:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)

oD300:setRelac(cChaveD010)
oD300:setnModelo(cEspecie)
oD300:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oD300:setnNumNf((cAliasSFT)->FT_NFISCAL)
oD300:setiCFOP((cAliasSFT)->FT_CFOP)
oD300:setEntrada((cAliasSFT)->FT_ENTRADA)
oD300:setValItem((cAliasSFT)->FT_TOTAL)
oD300:setiVaDesc((cAliasSFT)->FT_DESCONT + nValDesco)
oD300:setiValPis((cAliasSFT)->FT_VALPIS)
oD300:setiBasPis((cAliasSFT)->FT_BASEPIS)
oD300:setiAlqPis((cAliasSFT)->FT_ALIQPIS)
oD300:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oD300:setiValCof((cAliasSFT)->FT_VALCOF)
oD300:setiBasCof((cAliasSFT)->FT_BASECOF)
oD300:setiAlqCof((cAliasSFT)->FT_ALIQCOF)
oD300:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oD300:setConta(cConta)
//Processa registro D300
oD300:AddD300()
cChaveD300:= oD300:getGrupo()

Return cChaveD300

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD350
@description Função para processar as informações do registro D350
			  Este registro é gerado através do ponto de entrada SPDPISTR
@param cChaveD010,String,Relação com registro pai D010
@param oD350,Objeto,Objeto da classe EFDCBLOCOD
@param aSPDPISTR,Array,Array com retorno da execução do ponto de entrada SPDPISTR
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcD350(cChaveD010, oD350, aSPDPISTR, cConta, cAliasSFT, lPISCOFP)

Local nVlBrtLj := 0
Local nAlqPisR := 0
Local nBasePisQ := 0
Local lPautPis := .F.
Local nAlqCofR	:= 0
Local nBaseCofQ	:= 0
Local lPautCof	:= .F.
Local cModECF := ""

DEFAULT cAliasSFT := ""
DEFAULT lPISCOFP := .F.
DEFAULT aSPDPISTR := {}

// Geração do registro SEM ponto de entrada...
If Len(aSPDPISTR) == 0 .And. !Empty(cAliasSFT)

	//JOAO: Usei o FT_VALCONT pois se usar o FI_VALCON na hora de quebrar o registro D350 o valor será
	//multiplicado, pois na redução-Z não há quebra por CST, por exemplo.

	//nVlBrtLj := (cAliasSFT)->FI_VALCON + (cAliasSFT)->FI_ISS + (cAliasSFT)->FT_DESCONT
	nVlBrtLj := (cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT
	cModECF := IIf(!Empty(Left((cAliasSFT)->LG_IMPFISC,21)), Left((cAliasSFT)->LG_IMPFISC,21), (cAliasSFT)->LG_SERPDV)

	oD350:setTNatRec((cAliasSFT)->FT_TNATREC)
	oD350:setCNatRec((cAliasSFT)->FT_CNATREC)
	oD350:setGNatRec((cAliasSFT)->FT_GRUPONC)
	oD350:setDNatRec((cAliasSFT)->FT_DTFIMNT)

	//Faz conversão de valores de pauta de PIS
	oD350:setVlPauta((cAliasSFT)->FT_PAUTPIS)
	oD350:setiQtde((cAliasSFT)->FT_QUANT)
	oD350:setiBsPaut((cAliasSFT)->FT_BASEPIS)

	IF oD350:OperPauta(PIS,lPISCOFP)
		nAlqPisR	:= oD350:getAlqReal()
		nBasePisQ	:= oD350:getBaseQtd()
		lPautPis	:= .T.
	EndIF

	//Faz conversão de valores de pauta de COFINS
	oD350:setVlPauta((cAliasSFT)->FT_PAUTCOF)
	oD350:setiQtde((cAliasSFT)->FT_QUANT)
	oD350:setiBsPaut((cAliasSFT)->FT_BASECOF)

	IF oD350:OperPauta(COFINS,lPISCOFP)
		nAlqCofR	:= oD350:getAlqReal()
		nBaseCofQ	:= oD350:getBaseQtd()
		lPautCof	:= .T.
	EndIF

	oD350:setRelac(cChaveD010)
	oD350:setnModelo(AModNot((cAliasSFT)->FT_ESPECIE))
	oD350:setModEcf(cModECF)
	oD350:setSerEcf((cAliasSFT)->LG_SERPDV)
	oD350:setEmissao((cAliasSFT)->FT_ENTRADA)
	oD350:setCro((cAliasSFT)->FI_CRO)
	oD350:setCrZ((cAliasSFT)->FI_NUMREDZ)
	oD350:setNumCont((cAliasSFT)->FI_COO)
	oD350:setVlGrade((cAliasSFT)->FI_GTFINAL)
	oD350:setVlBrut(nVlBrtLj)
	oD350:setiCSTPis((cAliasSFT)->FT_CSTPIS)
	oD350:setiBasPis(Iif(lPautPis, '', (cAliasSFT)->FT_BASEPIS))
	oD350:setiAlqPis(Iif(lPautPis, '', (cAliasSFT)->FT_ALIQPIS))
	oD350:setPisQtde(IIf(lPautPis, nBasePisQ, ''))
	oD350:setPautPis(IIf(lPautPis, nAlqPisR, ''))
	oD350:setiValPis((cAliasSFT)->FT_VALPIS)
	oD350:setiCSTCof((cAliasSFT)->FT_CSTCOF)
	oD350:setiBasCof(IIf(lPautCof, '', (cAliasSFT)->FT_BASECOF))
	oD350:setiAlqCof(IIf(lPautCof, '', (cAliasSFT)->FT_ALIQCOF))
	oD350:setCofQtde(IIf(lPautCof, nBaseCofQ, ''))
	oD350:setPautCof(IIf(lPautCof, nAlqCofR, ''))
	oD350:setiValCof((cAliasSFT)->FT_VALCOF)
	oD350:setConta(cConta)

	//Processa registro
	oD350:AddD350(.T.)

Else

	oD350:setRelac(cChaveD010)
	oD350:setnModelo(aSPDPISTR[2])
	oD350:setModEcf(aSPDPISTR[3])
	oD350:setSerEcf(aSPDPISTR[4])
	oD350:setEmissao(aSPDPISTR[5])
	oD350:setCro(aSPDPISTR[6])
	oD350:setCrZ(aSPDPISTR[7])
	oD350:setNumCont(aSPDPISTR[8])
	oD350:setVlGrade(aSPDPISTR[9])
	oD350:setVlBrut(aSPDPISTR[10])
	oD350:setiCSTPis(aSPDPISTR[11])
	oD350:setiBasPis(aSPDPISTR[12])
	oD350:setiAlqPis(aSPDPISTR[13])
	oD350:setPisQtde(aSPDPISTR[14])
	oD350:setPautPis(aSPDPISTR[15])
	oD350:setiValPis(aSPDPISTR[16])
	oD350:setiCSTCof(aSPDPISTR[17])
	oD350:setiBasCof(aSPDPISTR[18])
	oD350:setiAlqCof(aSPDPISTR[19])
	oD350:setCofQtde(aSPDPISTR[20])
	oD350:setPautCof(aSPDPISTR[21])
	oD350:setiValCof(aSPDPISTR[22])
	oD350:setConta(cConta)

	//Processa registro
	oD350:AddD350()

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD500
@description Função para processar as informações do registro D500
@param cChaveD010,String,Relação com registro pai D010
@param oD500,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcD500(cChaveD010, oD500, cAliasSFT, cCodPart,cCodInfCom,cEspecie,cConta,lSubserie, cEFDSerie,cSituaDoc)

Local cIndEmi		:= ''
Local cIndOper	:= ''
Local nRet			:= 0
Default	cConta		:= ''

cIndOper	:=	IndMovto((cAliasSFT)->FT_TIPOMOV)

//emissão do documento
cIndEmi:=IndEmit((cAliasSFT)->FT_FORMUL, cIndOper)

oD500:setRelac(cChaveD010)
oD500:setIndEmit(cIndEmi)
oD500:setCodPart(cCodPart)
oD500:setnModelo(cEspecie)
oD500:setnSitDoc(cSituaDoc)
oD500:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oD500:setnSubSerie( Iif( lSubserie  .and. (cAliasSFT)->FT_TIPOMOV == 'E', (cAliasSFT)->F1_SUBSERI,''))
oD500:setnNumNf((cAliasSFT)->FT_NFISCAL)
oD500:setEmissao((cAliasSFT)->FT_EMISSAO)
oD500:setEntrada((cAliasSFT)->FT_ENTRADA)
oD500:setVlNTrib(0)
oD500:setnInfCmp(cCodInfCom)
oD500:setConta(cConta)

nRet	:= oD500:AddD500(.T.)// Inclui novo D500

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcD501505
@description Função para processar as informações do registros D501 e D505
@param cChaveD200,String,Relação com registro pai D500
@param oD501D505,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcD501505(cChaveD200, oD501D505, cAliasSFT, nPosPai,cConta)

Local nVlTerc		:= 0
Local nDesp		:= 0
Local nVlPis		:= 0
Local nVlCof		:= 0
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Default cConta		:= ''

nVlTerc  := (cAliasSFT)->FX_VALTERC

If (cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE) > 0
	nDesp	:=	(cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE)
EndIf

nVlPis		:= (cAliasSFT)->FT_VALPIS
nAlqPis	:= (cAliasSFT)->FT_ALIQPIS
nVlCof		:= (cAliasSFT)->FT_VALCOF
nAlqCof	:= (cAliasSFT)->FT_ALIQCOF

//------------------------------------------------------------------------------------------
//Verifica se possui alíquota majorada, se for majorada então irá subtrair o valor majorado.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->FT_TIPOMOV == 'E'
	If (cAliasSFT)->FT_MALQPIS > 0
		nVlPis 	-= (cAliasSFT)->FT_MVALPIS
		nAlqPis	-= (cAliasSFT)->FT_MALQPIS
	EndIF

	IF (cAliasSFT)->FT_MALQCOF > 0
		nVlCof		-= (cAliasSFT)->FT_MVALCOF
		nAlqCof	-= (cAliasSFT)->FT_MALQCOF
	EndIF
EndIF

//------------------------------------------------------------
//Passa informações em comum para os registros D501 e D505
//------------------------------------------------------------
oD501D505:setRelac(cChaveD200)
oD501D505:setValItem((cAliasSFT)->FT_TOTAL)
oD501D505:setiCodBcc((cAliasSFT)->FT_CODBCC)
oD501D505:setConta(cConta)

//-------------------------------------
//Passa informações para registro D201
//-------------------------------------
oD501D505:setiBasPis((cAliasSFT)->FT_BASEPIS)
oD501D505:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oD501D505:setiAlqPis(nAlqPis)
oD501D505:setiValPis(nVlPis)
oD501D505:AddD501()

//-------------------------------------
//Passa informações para registro D205
//-------------------------------------
oD501D505:setiBasCof((cAliasSFT)->FT_BASECOF)
oD501D505:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oD501D505:setiAlqCof(nAlqCof)
oD501D505:setiValCof(nVlCof)
oD501D505:AddD505()

//Acumula valores para registro pai D500
oD501D505:setValorNf((cAliasSFT)->FT_VALCONT)
oD501D505:setnVlDesc((cAliasSFT)->FT_DESCONT)
oD501D505:setVlTerc(nVlTerc)
oD501D505:setDespesa(nDesp)
oD501D505:setBasIcms((cAliasSFT)->FT_BASEICM)
oD501D505:setValIcms((cAliasSFT)->FT_VALICM)
oD501D505:setnValPis(nVlPis)
oD501D505:setnValCof(nVlCof)
oD501D505:setVlServ((cAliasSFT)->FT_VALCONT)

oD501D505:AddD500(.F., nPosPai) //Acumula valores no registro D500

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcD600
@description Função para processar as informações do registro D500
@param cChaveD010,String,Relação com registro pai D010
@param oD600,Objeto,Objeto da classe EFDCBLOCOD
@param cAliasSFT,QUery,Query efetuado na SFT.
@param lMVESTTELE,Lógico, Indica se deverá realizar estorno para operações de telecomunicação
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcD600(cChaveD010, oD600, cAliasSFT,cCodMun,cEspecie,lMVESTTELE,cConta, cChaveNf, cEFDSerie, dMVICMDSDT)
Local nVlTerc		:= 0
Local nDesp			:= 0
Local nTpRec		:= 0
Local cCodClass		:= ''
Local cChaveD600	:= ''
Local lEstorno		:= .F.
Local cEntSai 		:= Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS 		:= (cAliasSFT)->FT_VALICM
Local cDedbspc 		:= (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  		:= (cAliasSFT)->FT_TIPO
Local nValDesco 	:= DedPisCof(oD600:getDedbpis(),oD600:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)
Default cConta 		:= ''

IF lMVESTTELE .AND.  (cAliasSFT)->FX_TIPOREC == "0" .AND. (cAliasSFT)->FX_ESTREC <> "2"
	lEstorno	:= .T.
EndIF

nTpRec   := (cAliasSFT)->FX_TIPOREC
nNatRec  := (cAliasSFT)->FX_TIPOREC
nVlTerc  := (cAliasSFT)->FX_VALTERC

IF !EmpTy((cAliasSFT)->FX_GRPCLAS)
	If Len(Alltrim((cAliasSFT)->FX_GRPCLAS)) == 2
		cCodClass	:= (cAliasSFT)->FX_GRPCLAS+(cAliasSFT)->FX_CLASSIF
	Else
		cCodClass	:= Iif("A"$(cAliasSFT)->FX_GRPCLAS,"10","0"+Alltrim((cAliasSFT)->FX_GRPCLAS))+(cAliasSFT)->FX_CLASSIF
	EndIf
EndIF

//Acumula valores para registro pai D600
If (cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE) > 0
	nDesp	:=	(cAliasSFT)->FT_DESPESA -((cAliasSFT)->FT_SEGURO + (cAliasSFT)->FT_FRETE)
EndIf
oD600:setRelac(cChaveD010)
oD600:setnModelo(cEspecie)
oD600:setCodMun(cCodMun)
oD600:setnSerie(ProcSerie((cAliasSFT)->FT_SERIE,cEspecie, cEFDSerie))
oD600:setTpRec(nTpRec)
oD600:setnDtDe(oD600:getDtDe())
oD600:setnDtAte(oD600:getDtAte())
oD600:setValorNf((cAliasSFT)->FT_VALCONT)
oD600:setnVlDesc((cAliasSFT)->FT_DESCONT + nValDesco)
oD600:setVlServ((cAliasSFT)->FT_BASEICM)
oD600:setVlTerc(nVlTerc)
oD600:setDespesa(nDesp)
oD600:setBasIcms((cAliasSFT)->FT_BASEICM)
oD600:setValIcms((cAliasSFT)->FT_VALICM)
oD600:setnValPis(Iif(lEstorno,0,(cAliasSFT)->FT_VALPIS))
oD600:setnValCof(Iif(lEstorno,0,(cAliasSFT)->FT_VALCOF))
oD600:setVlNTrib((cAliasSFT)->FT_OUTRICM)
oD600:AddD600(,cChaveNf)

//------------------------------------------------------------
//Passa informações em comum para os registros D601 e D605
//------------------------------------------------------------
cChaveD600	:= oD600:getGrupo()
oD600:setRelac(cChaveD600)
oD600:setValItem((cAliasSFT)->FT_TOTAL)
oD600:setConta(cConta)
oD600:setiVaDesc(Iif(lEstorno,(cAliasSFT)->FT_BASEPIS,(cAliasSFT)->FT_DESCONT + nValDesco))
oD600:setCodCla(cCodClass)

//-------------------------------------
//Passa informações para registro D601
//-------------------------------------
oD600:setiValPis(Iif(lEstorno,0,(cAliasSFT)->FT_VALPIS))
oD600:setiBasPis(Iif(lEstorno,0,(cAliasSFT)->FT_BASEPIS))
oD600:setiAlqPis((cAliasSFT)->FT_ALIQPIS)
oD600:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oD600:AddD601()

//-------------------------------------
//Passa informações para registro D605
//-------------------------------------
oD600:setiValCof(Iif(lEstorno,0,(cAliasSFT)->FT_VALCOF))
oD600:setiBasCof(Iif(lEstorno,0,(cAliasSFT)->FT_BASECOF))
oD600:setiAlqCof((cAliasSFT)->FT_ALIQCOF)
oD600:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oD600:AddD605()


Return cChaveD600

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1100
@description Função para gerar os registros 1100 de saldo de crédito de PIS

@param cChave1001,String,Relação com registro pai 1001
@param o1100,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasCCY,QUery,Query efetuado na CCY.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1100(cChave1001, o1100, cAliasCCY)

Local nCrdApu	:= 0
Local nVlDisp	:= 0
Local cPeriodo	:= ''

//Valor total do crédito soma crédito normal e extemporâneo
nCrdApu	:=(cAliasCCY)->CCY_TOTCRD+(cAliasCCY)->CCY_LEXTEM
//Valor disópnível é Crédito menos já utilizado anteriormente menos créditos de ressarcimento e /ou compensação
nVlDisp	:= nCrdApu - (cAliasCCY)->CCY_UTIANT - (cAliasCCY)->CCY_REANTE - (cAliasCCY)->CCY_COANTE
cPeriodo	:= (cAliasCCY)->CCY_PERIOD
IF Alltrim((cAliasCCY)->CCY_PERIOD) <> Alltrim((cAliasCCY)->CCY_MES+(cAliasCCY)->CCY_ANO)
	cPeriodo	:= (cAliasCCY)->CCY_MES+(cAliasCCY)->CCY_ANO
EndIF

o1100:setRelac(cChave1001)
o1100:setPerApu(cPeriodo)
o1100:setOriCrd((cAliasCCY)->CCY_ORICRE)
o1100:setCnpj((cAliasCCY)->CCY_CNPJ)
o1100:setCodCrd((cAliasCCY)->CCY_COD)
o1100:setTotApur((cAliasCCY)->CCY_TOTCRD)
o1100:setCrdExt((cAliasCCY)->CCY_LEXTEM)
o1100:setCrdApu(nCrdApu)
o1100:setCrdAnt((cAliasCCY)->CCY_UTIANT)
o1100:setVlRes((cAliasCCY)->CCY_REANTE)
o1100:setVlCom((cAliasCCY)->CCY_COANTE)
o1100:setVlDisp(nVlDisp)
o1100:setVlDesc((cAliasCCY)->CCY_CREDUT)
o1100:setVPedRes((cAliasCCY)->CCY_RESSA)
o1100:setVPedCom((cAliasCCY)->CCY_COMP)
o1100:setVlTranf(0)
o1100:setVlUtOut(0)
o1100:setSldCrd((cAliasCCY)->CCY_CRDISP)
//Processa registro 1100
o1100:Add1100()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1500
@description Função para gerar os registros 1500 de saldo de crédito de COFINS

@param cChave1001,String,Relação com registro pai 1001
@param o1500,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasCCW,QUery,Query efetuado na CCW.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1500(cChave1001, o1500, cAliasCCW)

Local nCrdApu	:= 0
Local nVlDisp	:= 0
Local cPeriodo	:= 11

//Valor total do crédito soma crédito normal e extemporâneo
nCrdApu	:=(cAliasCCW)->CCW_TOTCRD+(cAliasCCW)->CCW_LEXTEM
//Valor disópnível é Crédito menos já utilizado anteriormente menos créditos de ressarcimento e /ou compensação
nVlDisp	:= nCrdApu - (cAliasCCW)->CCW_UTIANT - (cAliasCCW)->CCW_REANTE - (cAliasCCW)->CCW_COANTE

cPeriodo	:= (cAliasCCW)->CCW_PERIOD
IF Alltrim((cAliasCCW)->CCW_PERIOD) <> Alltrim((cAliasCCW)->CCW_MES+(cAliasCCW)->CCW_ANO)
	cPeriodo	:= (cAliasCCW)->CCW_MES+(cAliasCCW)->CCW_ANO
EndIF
o1500:setRelac(cChave1001)
o1500:setPerApu(cPeriodo)
o1500:setOriCrd((cAliasCCW)->CCW_ORICRE)
o1500:setCnpj((cAliasCCW)->CCW_CNPJ)
o1500:setCodCrd((cAliasCCW)->CCW_COD)
o1500:setTotApur((cAliasCCW)->CCW_TOTCRD)
o1500:setCrdExt((cAliasCCW)->CCW_LEXTEM)
o1500:setCrdApu(nCrdApu)
o1500:setCrdAnt((cAliasCCW)->CCW_UTIANT)
o1500:setVlRes((cAliasCCW)->CCW_REANTE)
o1500:setVlCom((cAliasCCW)->CCW_COANTE)
o1500:setVlDisp(nVlDisp)
o1500:setVlDesc((cAliasCCW)->CCW_CREDUT)
o1500:setVPedRes((cAliasCCW)->CCW_RESSA)
o1500:setVPedCom((cAliasCCW)->CCW_COMP)
o1500:setVlTranf(0)
o1500:setVlUtOut(0)
o1500:setSldCrd((cAliasCCW)->CCW_CRDISP)
//Processa registro 1500
o1500:Add1500()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1300
@description Função para gerar os registros 1300 de saldo de retanção de PIS

@param cChave1001,String,Relação com registro pai 1001
@param o1300,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasSFV,QUery,Query efetuado na SFV.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//---------------------------------------------------------------------
Function Proc1300(cChave1001, o1300, cAliasSFV) 

Local nVDeduzido	:= 0
Local lRess   :=  (cAliasSFV)->(FieldPos("FV_RESSA"))>0
Local lCompl   :=  (cAliasSFV)->(FieldPos("FV_COMP"))>0
Local lReserv   :=  (cAliasSFV)->(FieldPos("FV_RESRET"))>0

// Exemplo : Total Retenção 2000 - Saldo Disponivel para Utilizar 1750 - (Utilizei Ressarcimento  250 -Utilizei Compensação 0)  
If lRess .and. lCompl .And. lReserv
	nVDeduzido	:= (cAliasSFV)->FV_TOTRET - (cAliasSFV)->FV_VLDISP - IIF((cAliasSFV)->FV_RESRET == '2', (cAliasSFV)->FV_RESSA + (cAliasSFV)->FV_COMP, 0)
Else
	nVDeduzido	:= (cAliasSFV)->FV_TOTRET - (cAliasSFV)->FV_VLDISP
EndIf

o1300:setRelac(cChave1001)
o1300:setNatRet((cAliasSFV)->FV_NATRET) // IND_NAT_RET 01
o1300:setPerRet((cAliasSFV)->FV_PER)    // PR_REC_RET  02
o1300:setMesAno((cAliasSFV)->FV_MESANO) 
o1300:setTotRet((cAliasSFV)->FV_TOTRET) // VL_RET_APU  04
o1300:setRetDed(nVDeduzido)             // VL_RET_DED  05
If lRess .and. lCompl // Verifico se existe os novos campos
	o1300:setRetRes((cAliasSFV)->FV_RESSA)  // VL_RET_PER 06
	o1300:setRetCom((cAliasSFV)->FV_COMP)   // VL_RET_DCOMP 07 
Else
	o1300:setRetRes(0)
	o1300:setRetCom(0)
Endif
//Conforme layout do EFD Contribuições o Campo 8 é formado com (campo 4 - 5 -6 -7
If lRess .and. lCompl // Verifico se existe os novos campos
	o1300:setSldRet((cAliasSFV)->FV_TOTRET - nVDeduzido - (cAliasSFV)->FV_RESSA - (cAliasSFV)->FV_COMP) // SLD_RET 08
Else
	o1300:setSldRet((cAliasSFV)->FV_VLDISP) // SLD_RET 08
EndIF
//Processa registro 1300
o1300:Add1300()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1700
@description Função para gerar os registros 1700 de saldo de retanção de COFINS

@param cChave1001,String,Relação com registro pai 1001
@param o1700,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasSFW,QUery,Query efetuado na SFW.
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1700(cChave1001, o1700, cAliasSFW)

Local nVDeduzido	:= 0
Local lRess   :=  (cAliasSFW)->(FieldPos("FW_RESSA"))>0
Local lCompl   :=  (cAliasSFW)->(FieldPos("FW_COMP"))>0
Local lReserv   :=  (cAliasSFW)->(FieldPos("FW_RESRET"))>0

// Exemplo : Total Retenção 2000 - Saldo Disponivel para Utilizar 1750 - (Utilizei Ressarcimento  250 -Utilizei Compensação 0) 
If lRess .and. lCompl .And. lReserv
	nVDeduzido	:= (cAliasSFW)->FW_TOTRET - (cAliasSFW)->FW_VLDISP - IIF((cAliasSFW)->FW_RESRET == '2', (cAliasSFW)->FW_RESSA + (cAliasSFW)->FW_COMP, 0)
Else
	nVDeduzido	:= (cAliasSFW)->FW_TOTRET - (cAliasSFW)->FW_VLDISP
EndIF

o1700:setRelac(cChave1001)
o1700:setNatRet((cAliasSFW)->FW_NATRET) // IND_NAT_RET 01
o1700:setPerRet((cAliasSFW)->FW_PER)  
o1700:setMesAno((cAliasSFW)->FW_MESANO) // PR_REC_RET  02
o1700:setTotRet((cAliasSFW)->FW_TOTRET) // VL_RET_APU  04
o1700:setRetDed(nVDeduzido)             // VL_RET_DED  05
If lRess .and. lCompl // Verifico se existe os novos campos
	o1700:setRetRes((cAliasSFW)->FW_RESSA)// VL_RET_PER 06
	o1700:setRetCom((cAliasSFW)->FW_COMP)// VL_RET_DCOMP 07 
Else
	o1700:setRetRes(0)
	o1700:setRetCom(0)
Endif
//Conforme layout do EFD Contribuições o Campo 8 é formado com (campo 4 - 5 -6 -7
If lRess .and. lCompl // Verifico se existe os novos campos
	o1700:setSldRet((cAliasSFW)->FW_TOTRET - nVDeduzido - (cAliasSFW)->FW_RESSA - (cAliasSFW)->FW_COMP) // SLD_RET 08
Else
	o1700:setSldRet((cAliasSFW)->FW_VLDISP) // SLD_RET 08
EndIf
//Processa registro 1700
o1700:Add1700()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1800
@description Função para geração do registro 1800, referente incorporação
			   imobiliária. Este registro é gerado através do Ponto de Entrada
			   SPDPC1800.

@param cChave1001,String,Relação com registro pai 1001
@param o1800,Objeto,Objeto da classe EFDCBLOCO1
@param aSPDPC1800,Array,Retorno do processamentyo do ponto de entrada SPDPC1800
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1800(cChave1001, o1800, aSPDPC1800)

Local nPos	:= 0

For nPos	:= 1 to Len(aSPDPC1800)

	o1800:setRelac(cChave1001)
	o1800:setIdEmpre(aSPDPC1800[nPos][2])
	o1800:setVlReceb(aSPDPC1800[nPos][3])
	o1800:setRecFin(aSPDPC1800[nPos][4])
	o1800:setiBasPis(aSPDPC1800[nPos][5])
	o1800:setiAlqPis(aSPDPC1800[nPos][6])
	o1800:setiValPis(aSPDPC1800[nPos][7])
	o1800:setDtRecol(aSPDPC1800[nPos][8])
	o1800:setCodRec(aSPDPC1800[nPos][9])
	//Processa registro 1800
	o1800:Add1800()
Next nPos

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1010
@description Função para processar informações do registro 1010, processo referenciado
			   Ação judicial
@param cChave1001,String,Relação com registro pai 1001
@param o1800,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasCCF,Query,Query efetuada ba tabela CCF
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1010(cChave1001, o1010, cAliasCCF, aPar)

Default aPar	:= {} //Este array será utilizado somente quando for gerando a partir de um Ponto de Entrada
o1010:setRelac(cChave1001)

IF Len(aPar) == 0
	o1010:setNumProc((cAliasCCF)->CCF_NUMERO)
	o1010:setIdJur( (cAliasCCF)->CCF_IDSEJU)
	o1010:setIdVara((cAliasCCF)->CCF_IDVARA)
	o1010:setNatAcao((cAliasCCF)->CCF_NATJU)
	o1010:setDescr((cAliasCCF)->CCF_DESCJU)
	o1010:setDecisao((cAliasCCF)->CCF_DTSENT)
Else
	o1010:setNumProc(aPar[2])
	o1010:setIdJur(aPar[3])
	o1010:setIdVara(aPar[4])
	o1010:setNatAcao(aPar[5])
	o1010:setDescr(aPar[6])
	o1010:setDecisao(aPar[7])
EndIF
//Adiciona registro 1010
o1010:Add1010()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1020
@description Função para processar informações do registro 1020, processo referenciado
			   Ação administrativa
@param cChave1001,String,Relação com registro pai 1001
@param o1800,Objeto,Objeto da classe EFDCBLOCO1
@param cAliasCCF,Query,Query efetuada ba tabela CCF
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1020(cChave1001, o1020, cAliasCCF, aPar)

Default aPar	:= {}

o1020:setRelac(cChave1001)
If Len(aPar) ==0
	o1020:setNumProc((cAliasCCF)->CCF_NUMERO)
	o1020:setNatAcao((cAliasCCF)->CCF_NATJU)
	o1020:setDecisao((cAliasCCF)->CCF_DTSENT)
Else
	o1020:setNumProc(aPar[2])
	o1020:setNatAcao(aPar[3])
	o1020:setDecisao(aPar[4])
EndIF
//Adiciona registro 1020
o1020:Add1020()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF150
@description Função para processar registro F150, valores de créditos de estoque
			   de abertura
@param cChaveF010,String,Relação com registro pai F010
@param oF150,Objeto,Objeto da classe EFDCBLOCOF
@param cAliasCCF,Query,Query efetuada ba tabela CCF
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF150(cChaveF010, oF150, cAliasCF9, cConta)

oF150:setRelac(cChaveF010)
oF150:setiCodBcc((cAliasCF9)->CF9_CODBCC)
oF150:setValEstq((cAliasCF9)->CF9_VLTEST)
oF150:setParEstq((cAliasCF9)->CF9_SCRED)
oF150:setBasEstq((cAliasCF9)->CF9_BASCAL)
oF150:setEstqMes((cAliasCF9)->CF9_BASMES)
oF150:setiCSTPis((cAliasCF9)->CF9_CSTPIS)
oF150:setiAlqPis((cAliasCF9)->CF9_ALQPIS)
oF150:setiValPis((cAliasCF9)->CF9_VALPIS)
oF150:setiCSTCof((cAliasCF9)->CF9_CSTCOF)
oF150:setiAlqCof((cAliasCF9)->CF9_ALQCOF)
oF150:setiValCof((cAliasCF9)->CF9_VALCOF)
oF150:setDescri((cAliasCF9)->CF9_DESCPR)
oF150:setConta(cConta)
//Adiciona registro F150 para ser processado
oF150:AddF150()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF200
@description Função para processar registro F200, operações de atividade
			   imobiliária. Este registro é gerado através do Ponto de Entrada
			   SPDPCIMOB.
@param cChaveF010,String,Relação com registro pai F010
@param oF200,Objeto,Objeto da classe EFDCBLOCOF
@param aSPDPCIMOB,array,Array com retorno das informações de F200 do PE
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF200(cChaveF010, oF200, oTabela, aSPDPCIMOB)

Local cChvF200	:= ''
Local nX			:= 0
Local nY			:= 0
Local nPost		:= 0

Local lF205		:= .F.
Local lF210		:= .F.

If Len(aSPDPCIMOB)>0 .And. ValType(aSPDPCIMOB[1]) == "A"

	If Len(aSPDPCIMOB)>1 .And. ValType(aSPDPCIMOB[2]) == "A"
		lF205	:= .T.
	EndIF

	If Len(aSPDPCIMOB)>2 .And. ValType(aSPDPCIMOB[3]) == "A"
		lF210		:= .T.
	EndIF

EndIF

//³Baseando-se no registro F200 (Pai) processo os filhos F205 e F210³
For nX:=1 To Len(aSPDPCIMOB[1])

	//Processa F200
	oF200:setRelac(cChaveF010)
	oF200:setTpOpImob(aSPDPCIMOB[1][nX][2])
	oF200:setTpUnImob(aSPDPCIMOB[1][nX][3])
	oF200:setNome(aSPDPCIMOB[1][nX][4])
	oF200:setDescri(aSPDPCIMOB[1][nX][5])
	oF200:setnNumNf(aSPDPCIMOB[1][nX][6])
	oF200:setCnpj(aSPDPCIMOB[1][nX][7])
	oF200:setEmissao(aSPDPCIMOB[1][nX][8])
	oF200:setTotImob(aSPDPCIMOB[1][nX][9])
	oF200:setRecAcum(aSPDPCIMOB[1][nX][10])
	oF200:setRecMes(aSPDPCIMOB[1][nX][11])
	oF200:setiCSTPis(aSPDPCIMOB[1][nX][12])
	oF200:setiBasPis(aSPDPCIMOB[1][nX][13])
	oF200:setiAlqPis(aSPDPCIMOB[1][nX][14])
	oF200:setiValPis(aSPDPCIMOB[1][nX][15])
	oF200:setiCSTCof(aSPDPCIMOB[1][nX][16])
	oF200:setiBasCof(aSPDPCIMOB[1][nX][17])
	oF200:setiAlqCof(aSPDPCIMOB[1][nX][18])
	oF200:setiValCof(aSPDPCIMOB[1][nX][19])
	oF200:setPercent(aSPDPCIMOB[1][nX][20])
	oF200:setNatImob(aSPDPCIMOB[1][nX][21])
	oF200:setnInfCmp(aSPDPCIMOB[1][nX][22])
	//Adiciona registro F200
	oF200:AddF200()

	//Pega chave do F200 pai para gerar os filhos
	cChvF200	:= oF200:getGrupo()

	//Faz geração do registro F205
	If lF205 .And. Len(aSPDPCIMOB[2])>=nX .And. ValType(aSPDPCIMOB[2][nX])=='A' .And. Len(aSPDPCIMOB[2][nX])>18 .And. aSPDPCIMOB[2][nX][2]=='F205'
		ProcF205(cChvF200, oF200, aSPDPCIMOB[2][nX])
 	EndIf

	//Faz regaralçao do registro F210
	If lF210
		nPost := aScan(aSPDPCIMOB[3],{|x| x[1] == nX})
		IF nPost > 0

			For nY:=nPost To Len(aSPDPCIMOB[3])
				If ValType(aSPDPCIMOB[3][nY])=="A" .AND. Len(aSPDPCIMOB[3][nY]) > 11 .AND. aSPDPCIMOB[3][nY][1] == nX .AND. aSPDPCIMOB[3][nY][2] == 'F210'
					 ProcF210(cChvF200, oF200, aSPDPCIMOB[3][nY])
				EndIf
			Next
		EndIF
	EndIF

	//Gravação dos registros na tabela temporária
	oTabela:GrvReg(oF200:getF200())


	oTabela:GrvReg(oF200:getF205())


	oTabela:GrvReg(oF200:getF210())


	oF200:clsF200()

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF205
@description Função para processar registro F205, operações de atividade
			   imobiliária-Custo orçado. Este registro é gerado através do
			   Ponto de Entrada  SPDPCIMOB.
@param cChaveF200,String,Relação com registro pai F200
@param oF205,Objeto,Objeto da classe EFDCBLOCOF
@param aSPDPCIMOB,array,Array com retorno das informações de F205 do PE
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF205(cChaveF200, oF205, aSPDPCIMOB)

oF205:setRelac(cChaveF200)
oF205:setCIncAnt(aSPDPCIMOB[3])
oF205:setCIncMes(aSPDPCIMOB[4])
oF205:setTotCinc(aSPDPCIMOB[5])
oF205:setExCInc(aSPDPCIMOB[6])
oF205:setiBasPis(aSPDPCIMOB[7])
oF205:setiCSTPis(aSPDPCIMOB[8])
oF205:setiAlqPis(aSPDPCIMOB[9])
oF205:setiValPis(aSPDPCIMOB[10])
oF205:setCPisAnt(aSPDPCIMOB[11])
oF205:setCPisMes(aSPDPCIMOB[12])
oF205:setCPisFut(aSPDPCIMOB[13])
oF205:setiCSTCof(aSPDPCIMOB[14])
oF205:setiAlqCof(aSPDPCIMOB[15])
oF205:setiValCof(aSPDPCIMOB[16])
oF205:setCCofAnt(aSPDPCIMOB[17])
oF205:setCCofMes(aSPDPCIMOB[18])
oF205:setCCOfFut(aSPDPCIMOB[19])
//Processa registro F205
oF205:AddF205()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF210
@description Função para processar registro F210, operações de atividade
			   imobiliária-Custo orçado. Este registro é gerado através do
			   Ponto de Entrada  SPDPCIMOB.
@param cChaveF200,String,Relação com registro pai F200
@param oF210,Objeto,Objeto da classe EFDCBLOCOF
@param aSPDPCIMOB,array,Array com retorno das informações de F210 do PE
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF210(cChaveF200, oF210, aSPDPCIMOB)

oF210:setRelac(cChaveF200)
oF210:setTotCOrc(aSPDPCIMOB[3])
oF210:setExCOrc(aSPDPCIMOB[4])
oF210:setBasCOrc(aSPDPCIMOB[5])
oF210:setiBasPis(aSPDPCIMOB[6])
oF210:setiCSTPis(aSPDPCIMOB[7])
oF210:setiAlqPis(aSPDPCIMOB[8])
oF210:setiValPis(aSPDPCIMOB[9])
oF210:setiCSTCof(aSPDPCIMOB[10])
oF210:setiAlqCof(aSPDPCIMOB[11])
oF210:setiValCof(aSPDPCIMOB[12])
//Processa registro F210
oF210:AddF210()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcF550560
@description Função para processar registros F550 e F560, são referentes
			   ao regime de competência consolidados. Este registro é gerado
			   de diversos lugares, por este motivo para que seja gerado
			   deverá preencher array com informações.
@param cChaveF010,String,Relação com registro pai F010
@param oF550F560,Objeto,Objeto da classe EFDCBLOCOF
@param aPar,array,Array com informações
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcF550560(cChaveF010, oF550F560, aPar)

oF550F560:setRelac(cChaveF010)
oF550F560:setRecAuf(aPar[1])
oF550F560:setiCSTPis(aPar[2])
oF550F560:setiVaDesc(aPar[3])
oF550F560:setiBasPis(aPar[4])
oF550F560:setiAlqPis(aPar[5])
oF550F560:setiValPis(aPar[6])
oF550F560:setiCSTCof(aPar[7])
oF550F560:setiVaDesc(aPar[8])
oF550F560:setiBasCof(aPar[9])
oF550F560:setiAlqCof(aPar[10])
oF550F560:setiValCof(aPar[11])
oF550F560:setnModelo(aPar[12])
oF550F560:setiCFOP(aPar[13])
oF550F560:setConta(aPar[14])
oF550F560:setDescri(aPar[15])
//Verifica através do CST, se operação é referente pauta
//Se for então deverá gerar F560, se não gerar F550
IF aPar[2] == '03'
	//gera registro F560
	oF550F560:AddF560()
Else
	//Gera registro F550
	oF550F560:AddF550()
EndIF
PutGlbValue( cChaveF010, ".F." )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF700
@description Função para geração do registro F700, Outras Deduções
			   que está gravado na tabela CF2.
@param cChaveF010,String,Relação com registro pai F010
@param oF700,Objeto,Objeto da classe EFDCBLOCOF
@param cAliasCF2,Query,Query realizada na tabela CF2
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF700(cChaveF010, oF700, cAliasCF2)

oF700:setRelac(cChaveF010)
oF700:setOriDed((cAliasCF2)->CF2_ORIDED)
oF700:setRegime((cAliasCF2)->CF2_INDNAT)
oF700:setDedPis((cAliasCF2)->CF2_DEDPIS)
oF700:setDedCof((cAliasCF2)->CF2_DEDCOF)
oF700:setBasDed((cAliasCF2)->CF2_BASE)
oF700:setCnpj((cAliasCF2)->CF2_CNPJ)
oF700:setDescri((cAliasCF2)->CF2_INFORM)
//Processa registro F700
oF700:AddF700()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1900
@description Função para processar registro 1900, tanto para regime
				de competência quanto para regime de caixa.
				Como este registro também é chamado de diversos lugares,
				as informações serão passadas via array.
@param cChave1001,String,Relação com registro pai 1001
@param o1900,Objeto,Objeto da classe EFDCBLOCO1
@param aPar,array,Array com informações
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc1900(cChave1001, o1900, aPar, lAgr1900)
Default lAgr1900 := .F.

o1900:setRelac(cChave1001)
o1900:setCnpj(aPar[1])
o1900:setModelo(aPar[2])
o1900:setSerie(aPar[3])
//Se a situação do documento não for normal (00) ou cancelado (02) deverá ser igual a 99 - Outros
If aPar[4] $ "00|02"
	o1900:setSitDoc(aPar[4])
Else
	o1900:setSitDoc("99")
EndIf
o1900:setVlRec(aPar[5])
o1900:setQtdNf(aPar[6])
o1900:setiCSTPis(aPar[7])
o1900:setiCstCof(aPar[8])
o1900:setiCFOP(aPar[9])
o1900:setInfComp(aPar[10])
o1900:setConta(aPar[11])
o1900:Add1900(lAgr1900)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM211611
@description Função para processar registros M211 e M611, referentes
			   a exclusões de sociedade cooperativa.
			   as informações virão através de array de parâmetros, pois somente
			   metade das informações estão gravadas na tabela CE9, outra parte estará
			   na pergunta SX1 e outra parte virá no momento que gerar registro M210.
			   A primeira informação do array de parâmetro deverá ser o tributo, se PIS eou COFINS.
@param cChaveMX10,String,Relação com registro pai M210/M610
@param oM211M611,Objeto,Objeto da classe EFDCBLOCOM
@param aPar,array,Array com informações
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcM211611(cChaveMX10, oM211M611, aPar, cTrib)

oM211M611:setRelac(cChaveMX10)
oM211M611:setIndSoc(aPar[1])
oM211M611:setSocACDF(aPar[2])
oM211M611:setExcES(aPar[3])
oM211M611:setExcET(aPar[4])

IF cTrib == 'PIS'
	//Processa registro M211 para exclusões de PIS
	oM211M611:AddM211()
ElseIF cTrib == 'COF'
	//Processa registro M611 para exclusões de COFINS
	oM211M611:AddM611()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM230630
@description Função para processar registro de diferimento do período
			   M230 e M630. Este registro também as informaç
@param cAliasCFA,String,Relação com registro pai M210/M610
@param oM230M630,Objeto,Objeto da classe EFDCBLOCOM
@param cAliasCFA,Query,Query na tabela CFA
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcM230630(cChaveMX10, oBlocoM, cAliasCFA)

oBlocoM:setRelac(cChaveMX10)
oBlocoM:setCNPJ((cAliasCFA)->CFA_CNPJ)
oBlocoM:setTotVend((cAliasCFA)->CFA_TOTVEN)
oBlocoM:setNReceb((cAliasCFA)->CFA_VLNREC)
oBlocoM:setConDif((cAliasCFA)->CFA_CONDIF)
oBlocoM:setCrdDif((cAliasCFA)->CFA_CREDIF)
oBlocoM:setCodCrd((cAliasCFA)->CFA_CODCRE)

//Verificar o tributo, para PIS gera M230
//Para COFINS gera M630
IF (cAliasCFA)->CFA_TPCON == 'PIS'
	oBlocoM:AddM230()
ElseIF (cAliasCFA)->CFA_TPCON == 'COF'
	oBlocoM:AddM630()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcM700300
@description Função para processar registro de diferimento do período
			   M230 e M630. Este registro também as informaç
@param cChaveMX00,String,Relação com registro pai M200/M600
@param oM230M630,Objeto,Objeto da classe EFDCBLOCOM
@param cAliasCFB,Query,Query na tabela CFB
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcM700300(cChaveMX00, oM300M600, cAliasCFB)

oM300M600:setRelac(cChaveMX00)
oM300M600:setCodCon((cAliasCFB)->CFB_CODCON)
oM300M600:setConDifA((cAliasCFB)->CFB_CONREC)
oM300M600:setNatCrd((cAliasCFB)->CFB_NATCRE)
oM300M600:setCrdDesc((cAliasCFB)->CFB_CREDES)
oM300M600:setVlConPe((cAliasCFB)->CFB_CONREC-(cAliasCFB)->CFB_CREDES)
oM300M600:setPer((cAliasCFB)->CFB_PERDIF)
oM300M600:setDtOper((cAliasCFB)->CFB_DTPGTO)

//Verificar o tributo, para PIS gera M300
//Para COFINS gera M700
IF (cAliasCFB)->CFB_TPCON == 'PIS'
	oM300M600:AddM300()
ElseIF (cAliasCFB)->CFB_TPCON == 'COF'
	oM300M600:AddM700()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0035
@description Processa informações de identificação de SCP
@param cChave0001,String,Relação com registro pai 0001
@param oM230M630,Objeto,Objeto da classe EFDCBLOCO0
@param cIdScp,String,Identificação da SCP
@param cNome,String,Nome da SCP
@param cInfComp,String,Informação complementar
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0035(cChave0001, o0035, cIdScp, cNome, cInfComp  )

o0035:setRelac(cChave0001)
o0035:setIdScp(cIdScp)
o0035:setNome(cNome)
o0035:setInfComp(cInfComp)
//Processa registro 0035
o0035:Add0035()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0120
@description Processa informações do registro 0120, identificando
			   os períodos de dispensa da obrigação acessória.
@param cChave0001,String,Relação com registro pai 0001
@param o0120,Objeto,Objeto da classe EFDCBLOCO0
@param cMes,String,Mês da dispensa
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0120(cChave0001, o0120, cMes, cInf)

o0120:setRelac(cChave0001)
o0120:setMes(cMes)
o0120:setInfComp(cInf)
//adiciona registro 0120
o0120:Add0120()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcIdEstab
@description Esta função irá processar os registros de identificação
			   do estabelecimento A010, C010, D010, F010, I010 e P010
@param cChave,String,Relação com registro pai 0001
@param oIdEstab,Objeto,Objeto da classe NOTAEFD
@param cReg,String,Registro a ser processaddo
@param cCnpj,String,CNPJ do estabelecimento
@param cIdent,String,Identificação de escrituração para o bloco C
@param cInfComp,String,Inormação complementar para geração do bloco I
@author Erick G. Dias
@since 13/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcIdEstab(cChave, oIdEstab, oTabela, cReg, cCnpj, cIdent, cInfComp)

oIdEstab:setRelac(cChave)
oIdEstab:setRegistr(cReg)
oIdEstab:setCnpj(cCnpj)
//Somente para registros C010 e I010 passamos as demais informações
If cReg == 'C010'
	oIdEstab:setInd(cIdent)
ElseIF cReg == 'I010'
	oIdEstab:setInd(cIdent)
	oIdEstab:setInfComp(cInfComp)
EndIF

//Processa registro
Do Case
	Case cReg == 'A010'
		oIdEstab:AddA010()
		//oTabela:GrvReg(oIdEstab:AddA010())
		//
	Case cReg == 'C010'
		oIdEstab:AddC010()
		//oTabela:GrvReg(oIdEstab:AddC010())
		//
	Case cReg == 'D010'
		oIdEstab:AddD010()
		//oTabela:GrvReg()
		//
	Case cReg == 'F010'
		oIdEstab:AddF010()
		//oTabela:GrvReg(oIdEstab:AddF010())

	Case cReg == 'I010'
		oIdEstab:AddI010()
		//oTabela:GrvReg(oIdEstab:AddI010())

	Case cReg == 'P010'
		oIdEstab:AddP010()
		//oTabela:GrvReg(oIdEstab:AddP010())

EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0000
@description Função para geração do registro 0000, registro de abertura da EFD.
@param o0000,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0000(o0000, aPar, oTabela)

o0000:setRelac()
o0000:setVersao(aPar[1])
o0000:setTpEscri(aPar[2])
o0000:setSitEsp(aPar[3])
o0000:setRecibo(aPar[4])
o0000:setDtIni(aPar[5])
o0000:setDtFin(aPar[6])
o0000:setNome(aPar[7])
o0000:setCnpj(aPar[8])
o0000:setUF(aPar[9])
o0000:setCodMun(aPar[10])
o0000:setSuframa(aPar[11])
o0000:setNAtPj(aPar[12])
o0000:setAtivid(aPar[13])

oTabela:GrvReg(o0000:Add0000())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0100
@description Função para geração do registro 0000, registro de abertura da EFD.
@param cChave0000,String,Chave de relação com regitro pai 0000
@param o1000,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0100(cChave0000,o0100, aPar,oTabela)

o0100:setRelac(cChave0000)
o0100:setNome(aPar[1])
o0100:setCpf(aPar[2])
o0100:setCrc(aPar[3])
o0100:setCnpj(aPar[4])
o0100:setCep(aPar[5])
o0100:setEnder(aPar[6])
o0100:setNumEnd(aPar[7])
o0100:setCompEnd(aPar[8])
o0100:setBairro(aPar[9])
o0100:setTel(aPar[10])
o0100:setFax(aPar[11])
o0100:setEmail(aPar[12])
o0100:setCodMun(aPar[13])

oTabela:GrvReg(o0100:Add0100())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0110
@description Função para geração do registro 0110, registro de abertura da EFD.
@param cChave0000,String,Chave de relação com regitro pai 0000
@param o0110,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0110(cChave0000,o0110, aPar, oTabela)

o0110:setRelac(cChave0000)
o0110:setIndTrib(aPar[1])
o0110:setIndApro(aPar[2])
o0110:setConApu(aPar[3])
o0110:setCrtLp(aPar[4])

oTabela:GrvReg(o0110:Add0110())


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0140
@description Função para geração do registro 0140, cadastro de estabelecimento.
@param cChave0000,String,Chave de relação com regitro pai 0000
@param o0140,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0140(cChave0000,o0140, aPar)

o0140:setRelac(cChave0000)
o0140:setCodEsta(aPar[1])
o0140:setNome(aPar[2])
o0140:setCnpj(aPar[3])
o0140:setUF(aPar[4])
o0140:setIe(aPar[5])
o0140:setCodMun(aPar[6])
o0140:setIm(aPar[7])
o0140:setSuframa(aPar[8])

o0140:Add0140()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0145
@description Função para geração do registro 0145, Regime de apuração da CPRB
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0145,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function Proc0145(cChave0140,o0145, aPar)

o0145:setRelac(cChave0140)
o0145:setIncPer(aPar[1])
o0145:setRecBrut(aPar[2])
o0145:setRecAtiv(aPar[3])
o0145:setRecCPR(aPar[4])
o0145:setInfComp(aPar[5])
//Adiciona registro 0145
o0145:Add0145()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0150
@description Função para processar registro 0150, cadastro de participantes.
			   O código do particioante deste registro será utilizado
			   nos demais blocos que tiverem em suas operações o fornecedor
			   ou cliente aqui cadastrados.
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0150,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0150(cChave0140,o0150, aPar)

o0150:setRelac(cChave0140)
o0150:setCodPart(aPar[3])
o0150:setNome(aPar[4])
o0150:setCodPais(aPar[5])
o0150:setCnpj(aPar[6])
o0150:setCpf(aPar[7])
o0150:setIe(aPar[8])
o0150:setCodMun(aPar[9])
o0150:setSuframa(aPar[10])
o0150:setEnder(aPar[11])
o0150:setNumEnd(aPar[12])
o0150:setCompEnd(aPar[13])
o0150:setBairro(aPar[14])
//Adiciona novo registro 0150
o0150:Add0150()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0190
@description Função para geração do registro 0190. Registro com informações
			   de unidade de medida.
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0190,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0190(cChave0140,o0190, aPar)

o0190:setRelac(cChave0140)
o0190:setUnMedid(aPar[1])
o0190:setDescr(aPar[2])
o0190:Add0190()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0200
@description Função para geração do registro 0200. Este registro terá as
			   as informações de todos os produtos utilizados nos blocos da
			   EFD.
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0190,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0200(cChave0140,o0200, aPar)

o0200:setRelac(cChave0140)
o0200:setCodItem(aPar[1])
o0200:setDescr(aPar[2])
o0200:setCodBarr(aPar[3])
o0200:setCodAnt(aPar[4])
o0200:setUnMedid(aPar[5])
o0200:setTpItem(aPar[6])
o0200:setNcm(aPar[7])
o0200:setExIp(aPar[8])
o0200:setGenero(aPar[9])
o0200:setLst(aPar[10])
o0200:setAqlIcms(aPar[11])
//Processa registro 0200
o0200:Add0200()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0205
@description Função para geração do registro 0205. Este registro terá informações
			   sobre alterações do produto.
@param cChave0200,String,Chave de relação com regitro pai 0200
@param o0205,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0205(cChave0200,o0205, aPar)

o0205:setRelac(cChave0200)
o0205:setDescr(aPar[1])
o0205:setDtIni(aPar[2])
o0205:setDtFin(aPar[3])
o0205:setCodAnt(aPar[4])
o0205:Add0205()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0206
@description Função para geração do registro 0206. Este registro terá informações
			   sobre código da tabela ANP para combustíveis.
@param cChave0200,String,Chave de relação com regitro pai 0200
@param o0206,Objeto,Objeto da classe EFDCBLOCO0
@param cCodAnp,String,Código da tabela ANP
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0206(cChave0200,o0206, cCodAnp)

o0206:setRelac(cChave0200)
o0206:setCodAnp(cCodAnp)
o0206:Add0206()


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0208
@description Função para geração do registro 0208. Grupo de marca comercial
			  referente a bebidas.
@param cChave0200,String,Chave de relação com regitro pai 0200
@param o0208,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0208(cChave0200,o0208, aPar)

o0208:setRelac(cChave0200)

o0208:setTabMarc(aPar[1])
o0208:setGrpMarc(aPar[2])
o0208:setDescr(aPar[3])

o0208:Add0208()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0400
@description Função para geração do registro 0400.Natureza da operação/prestação
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0400,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0400(cChave0140,o0400, aPar)

o0400:setRelac(cChave0140)
o0400:setNatOper(aPar[1])
o0400:setDescr(aPar[2])
//Adiciona registro 0400
o0400:Add0400()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0450
@description Função para geração do registro 0450.Informação complementar
@param cChave0140,String,Chave de relação com regitro pai 0140
@param o0450,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0450(cChave0140,o0450, aPar)

o0450:setRelac(cChave0140)
o0450:setCodInfo(aPar[1])
o0450:setDescr(aPar[2])
o0450:Add0450()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0500
@description Função para geração do registro 0500.
			   Cadastro de Centro de custo
@param cChave0001,String,Chave de relação com regitro pai 0001
@param o0500,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0500(cChave0001,o0500, aPar)

o0500:setRelac(cChave0001)
o0500:setDtIni(aPar[1])
o0500:setNatCtb(aPar[2])
o0500:setTpCtb(aPar[3])
o0500:setNivel(aPar[4])
o0500:setCodCtb(aPar[5])
o0500:setNome(aPar[6])
o0500:setCodRfb(aPar[7])
o0500:setCnpj(aPar[8])
o0500:Add0500()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc0600
@description Função para geração do registro 0600.
			   Cadastro de Conta Contábil
@param cChave0001,String,Chave de relação com regitro pai 0001
@param o0600,Objeto,Objeto da classe EFDCBLOCO0
@param aPar,Array,Array com informações a serem geradas no registro
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function Proc0600(cChave0001,o0600, aPar)

o0600:setRelac(cChave0001)
o0600:setDtIni(aPar[1])
o0600:setCCusto(aPar[2])
o0600:setDescr(aPar[3])
o0600:Add0600()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProceRefer
@description Função para processar registros de processo referenciado
			   de todos os blocos.
@param cChave,String,Relação com registro pai
@param oProc,Objeto,Objeto da classe EFDCBLOCOA,EFDCBLOCOC, EFDCBLOCOA, EFDCBLOCOF, EFDCBLOCOI ou EFDCBLOCOP
@param cReg,String,Registro que deverá ser gerado
@param cNum,String,Número do processo referenciado
@param cInd,String,Indicador do processo referenciado
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcRefC(cChave, oProc, cReg, cNum, cInd)

oProc:setRelac(cChave)
oProc:setProRef(cNum)
oProc:setTProRef(cInd)
//Adiciona registro de processo refereniado
oProc:AddProcRef(cReg)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC110
@description Função para processar geração do registro C100
@param cChaveC100,String,Relação com registro pai C100
@param oC110,Objeto,Objeto da classe EFDCBLOCOC
@param aPar,Array,Array com informações do registro
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC110(cChaveC100, oC110, aPar)


oC110:setRelac(cChaveC100)
oC110:setCodInfC(aPar[1])
oC110:setDescri(aPar[2])
//Adiciona registro
oC110:AddC110()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcA110
@description Função para processar geração do registro A110
@param cChaveA100,String,Relação com registro pai A100
@param oA110,Objeto,Objeto da classe EFDCBLOCOA
@param aPar,Array,Array com informações do registro
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcA110(cChaveA100, oA110, aPar)

oA110:setRelac(cChaveA100)
oA110:setCodInfC(aPar[1])
oA110:setDescri(aPar[2])
//Adiciona registro
oA110:AddA110()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcAbreBlc
@description Função que processa registros de abertura do bloco
@param PrcAbreBlc,String,Relação com registro pai
@param oAbertura,Objeto,Objeto da classe EFDCBLOCO0, EFDCBLOCO0, EFDCBLOCOA, EFDCBLOCOC, EFDCBLOCOD, EFDCBLOCOF, EFDCBLOCOI, EFDCBLOCOM, EFDCBLOCOP
@param cIndMovto,String,Indicador de movimento 0=Dados informados / 1=Sem dados informados
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcAbreBlc(cChave, oAbertura, cReg, cIndMovto,oTabela)

oAbertura:setRelac(cChave)

Do case

	Case cReg == '0001'
		oTabela:GrvReg(oAbertura:Add0001(cIndMovto))

	Case cReg == '1001'
		oTabela:GrvReg(oAbertura:Add1001(cIndMovto))

	Case cReg == 'A001'
		oTabela:GrvReg(oAbertura:AddA001(cIndMovto))

	Case cReg == 'C001'
		oTabela:GrvReg(oAbertura:AddC001(cIndMovto))

	Case cReg == 'D001'
		oTabela:GrvReg(oAbertura:AddD001(cIndMovto))

	Case cReg == 'F001'
		oTabela:GrvReg(oAbertura:AddF001(cIndMovto))

	Case cReg == 'I001'
		oTabela:GrvReg(oAbertura:AddI001(cIndMovto))

	Case cReg == 'M001'
		oTabela:GrvReg(oAbertura:AddM001(cIndMovto))

	Case cReg == 'P001'
		oTabela:GrvReg(oAbertura:AddP001(cIndMovto))

	Case cReg == '9001'
		oTabela:GrvReg(oAbertura:Add9001(cIndMovto))

EndCase
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcEncBlc
@description Função que processa registros de encerramento do bloco
@param PrcAbreBlc,String,Relação com registro pai
@param oAbertura,Objeto,Objeto da classe EFDCBLOCO0, EFDCBLOCO0, EFDCBLOCOA, EFDCBLOCOC, EFDCBLOCOD, EFDCBLOCOF, EFDCBLOCOI, EFDCBLOCOM, EFDCBLOCOP
@param nQtd,Integer,Quantidade de linhas
@author Erick G. Dias
@since 14/11//2014
@version 11.90
/*/
//-------------------------------------------------------------------
Function PrcEncBlc(cChave, oEncerra, cReg, nQtd,otabela)

oEncerra:setRelac(cChave)

Do case
	Case cReg == '0990'
		oTabela:GrvReg(oEncerra:Add0990(nQtd))

	Case cReg == '1990'
		oTabela:GrvReg(oEncerra:Add1990(nQtd))

	Case cReg == 'A990'
		oTabela:GrvReg(oEncerra:AddA990(nQtd))

	Case cReg == 'C990'
		oTabela:GrvReg(oEncerra:AddC990(nQtd))

	Case cReg == 'D990'
		oTabela:GrvReg(oEncerra:AddD990(nQtd))

	Case cReg == 'F990'
		oTabela:GrvReg(oEncerra:AddF990(nQtd))

	Case cReg == 'I990'
		oTabela:GrvReg(oEncerra:AddI990(nQtd))

	Case cReg == 'M990'
		oTabela:GrvReg(oEncerra:AddM990(nQtd))

	Case cReg == 'P990'
		oTabela:GrvReg(oEncerra:AddP990(nQtd))

	Case cReg == '9990'
		oTabela:GrvReg(oEncerra:Add9990(nQtd))

	Case cReg == '9999'
		oTabela:GrvReg(oEncerra:Add9999(nQtd))

EndCase
Return

Function PrcReg9900(oObj9900, cReg, cQtd)

oObj9900:Add9900(cReg,cQtd)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCFB
@description Função que irá buscar informações da tabela CFB para geração dos
			   registros M300 e M700, diferimento de período anterior.
@param dDataDe,Date,Data inicial de geração do arquivo
@param cTrib,Strin,Indica qual tributo está sendo processado
@param cChaveMX00,Integer,Chave do registro pai M010
@param oBlocoM,Objeto,Objeto da classe do bloco M
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function ProcCFB(dDataDe, cTrib,cChaveMX00, oBlocoM,aSM0,lConsol)

Local cChave	:= ''
Local cPeriodo	:= Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)
Local aAreaSM0  := {}
Local nContFil  := 0
Local lDifMatriz	:= findfunction("ISA001NDIF") .AND. ISA001NDIF()

//Busca as filiais selecionadas pelo usuário
aAreaSM0 := SM0->(GetArea())

For nContFil := 1 to Len(aSM0)
	
	SM0->(DbGoTop ())
	SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL
	
	IF	CFB->(MsSeek (xFilial ("CFB")+cPeriodo+cTrib))

		cChave := CFB->CFB_FILIAL+CFB->CFB_PERAPU+CFB->CFB_TPCON

		Do while !CFB->(Eof()) .And. CFB->CFB_FILIAL+CFB->CFB_PERAPU+CFB->CFB_TPCON==cChave
		
			//Novo processo
			IF (lConsol .AND. CFB->CFB_CONSOL == '1') .OR. (!lConsol .AND. CFB->CFB_CONSOL == '2' )
			   	PrcM700300(cChaveMX00, oBlocoM, 'CFB')
			Endif

			CFB->(DbSkip())
		Enddo

	EndIF

Next nContFil

SM0->(RestArea(aAreaSM0))
cFilAnt := FWGETCODFILIAL

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcCFA
@description Função que irá buscar informações da tabela CFB para geração dos
			   registros M300 e M700, diferimento de período anterior.
@param dDataDe,Date,Data inicial de geração do arquivo
@param cTrib,Strin,Indica qual tributo está sendo processado
@param cChaveMX00,Integer,Chave do registro pai M010
@param oBlocoM,Objeto,Objeto da classe do bloco M
@author Erick G. Dias
@since 09/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------

Static Function ProcCFA(dDataDe, cTrib,cCodCon,cChaveMX00, oBlocoM,aSM0,lConsol)

Local cPeriodo		:= Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)
Local cChave		:= ''
Local aAreaSM0  	:= {}
Local nContFil  	:= 0
Local lDifMatriz	:= findfunction("ISA001NDIF") .AND. ISA001NDIF()

//Busca as filiais selecionadas pelo usuário
aAreaSM0 := SM0->(GetArea())

For nContFil := 1 to Len(aSM0)
	IF !lDifMatriz

		SM0->(DbGoTop ())
		SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

	EndIF

	IF	CFA->(MsSeek (xFilial ("CFA")+cPeriodo+cTrib+Alltrim(cCodCon)))

		cChave := CFA->CFA_FILIAL+CFA->CFA_PERAPU+CFA->CFA_TPCON+CFA->CFA_CODCON

		Do while !CFA->(Eof())
			If CFA->CFA_FILIAL+CFA->CFA_PERAPU+CFA->CFA_TPCON+CFA->CFA_CODCON==cChave

				IF lDifMatriz
					//Novo processo
					IF (lConsol .AND. CFA->CFA_CONSOL == '1') .OR. (!lConsol .AND. CFA->CFA_CONSOL == '2' )
						PrcM230630(cChaveMX00, oBlocoM, 'CFA')
					EndIF
				Else
					//Legado
					PrcM230630(cChaveMX00, oBlocoM, 'CFA')
				EndIF

			EndIF

			CFA->(DbSkip())
		Enddo

	EndIF

	IF lDifMatriz
		//Quando diferimento é processado diretamente na FISA001, não precisa rodar todas as filiais, somente se foi processado pela FISA054
		Exit
	EndIF

Next nContFil

SM0->(RestArea(aAreaSM0))
cFilAnt := FWGETCODFILIAL

Return

Static Function ProcCE9(cChaveMX10,dDataDe,cCodCont,cAlq,nBaseAnt,oBlocoM,cTrib)

Local nVlBase	:=0
Local aPar	:= {}
Local cPeriodo	:= Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)

dbSelectArea('CE9')

If cTrib == 'PIS'
	CE9->(DbSetOrder (2))
Else
	CE9->(DbSetOrder (3))
EndIF

If MsSeek(xFilial('CE9')+cPeriodo+cCodCont+cAlq)

	If cCodCont $'03/53' //Base é por unidade de medida de produto, o valor da base deve ser zero.
		nBaseAnt	:= 0
	EndIF

	aAdd(aPar,mv_par14)
	aAdd(aPar,nBaseAnt)

	If cTrib == 'PIS'
		aAdd(aPar,CE9->CE9_EXGPIS)
		aAdd(aPar,CE9->CE9_EXEPIS)
	Else
		aAdd(aPar,CE9->CE9_EXGCOF)
		aAdd(aPar,CE9->CE9_EXECOF)
	EndIF

	PrcM211611(cChaveMX10, oBlocoM, aPar,cTrib)

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC860
@description Função para processar registros C860
@param cChaveC110,String,Relação com registro pai C110
@param oC860,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Mauro A. Gonçalves
@since 04/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC860(cChaveC110, oC860, cAliasSFT)

Local cSerSat	:=''

IF (cAliasSFT)->(FieldPos("FT_SERSAT"))>0
	cSerSat	:= (cAliasSFT)->FT_SERSAT
EndIF

oC860:setRelac(cChaveC110)
oC860:setNumSAT(cSerSat)
oC860:setEmissao((cAliasSFT)->FT_EMISSAO)
oC860:setnNumNf(Right(AllTrim((cAliasSFT)->FT_NFISCAL),6))
oC860:setnNumNf(Right(AllTrim((cAliasSFT)->FT_NFISCAL),6))
oC860:AddC860()

Return oC860:getGrupo()

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC870
@description Função para processar registros C870
@param cChaveC110,String,Relação com registro pai C860
@param oC870,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Mauro A. Gonçalves
@since 04/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC870(cChaveC860, oC870, oBloco0, oTabela, lConcFil, cAliasSFT, cCodProd, cConta, dMVICMDSDT)

Local nVlPis		:= (cAliasSFT)->FT_VALPIS
Local nVlCof		:= (cAliasSFT)->FT_VALCOF
Local nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
Local nAlqCof		:= (cAliasSFT)->FT_ALIQCOF
Local nBasePis	:= (cAliasSFT)->FT_BASEPIS
Local nBaseCof	:= (cAliasSFT)->FT_BASECOF
Local cEntSai := Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS := (cAliasSFT)->FT_VALICM
Local cDedbspc := (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  := (cAliasSFT)->FT_TIPO
Local nValDesco := DedPisCof(oC870:getDedbpis(),oC870:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)

//-------------------------------------------------------------------------------------------
//Irá verificar se a nota fiscal foi devolvida no mesmo período. Se sim irá reduzir valor
//da base de cálculo e valor da contribuição.
//-------------------------------------------------------------------------------------------
If (cAliasSFT)->CF4_VALPIS > 0
	nVlPis		-= (cAliasSFT)->CF4_VALPIS
	nBasePis	-= (cAliasSFT)->CF4_BASPIS
EndIF

If (cAliasSFT)->CF4_VALCOF > 0
	nVlCof		-= (cAliasSFT)->CF4_VALCof
	nBaseCof	-= (cAliasSFT)->CF4_BASCof
EndIF

IF nBaseCof < nBasePis .AND. ((cAliasSFT)->CF4_VALPIS> 0 .OR. (cAliasSFT)->CF4_VALCOF> 0)
	nBasePis :=	nBaseCof
EndIF

oC870:setRelac(cChaveC860)
oC870:setCodItem(cCodProd)
oC870:setiCFOP((cAliasSFT)->FT_CFOP)
oC870:setValItem((cAliasSFT)->FT_TOTAL)
oC870:setiVaDesc(IIf((cAliasSFT)->F4_PISCRED=="5", (cAliasSFT)->FT_TOTAL, (cAliasSFT)->FT_DESCONT + nValDesco))
oC870:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC870:setiBasPis(nBasePis)
oC870:setiAlqPis(nAlqPis)
oC870:setiValPis(nVlPis)
oC870:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC870:setiBasCof(nBaseCof)
oC870:setiAlqCof(nAlqCof)
oC870:setiValCof(nVlCof)
oC870:setConta(cConta)
oC870:AddC870()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcC880
@description Função para processar registros C880
@param cChaveC110,String,Relação com registro pai C860
@param oC880,Objeto,Objeto da classe EFDCBLOCOC
@param cAliasSFT,QUery,Query efetuado na SFT.
@author Mauro A. Gonçalves
@since 04/08/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcC880(cChaveC860, oC880, oBloco0, oTabela, lConcFil, cAliasSFT, cCodProd, cConta, dMVICMDSDT)

Local nVlPis		:= (cAliasSFT)->FT_VALPIS
Local nVlCof		:= (cAliasSFT)->FT_VALCOF
Local nAlqPis		:= (cAliasSFT)->FT_ALIQPIS
Local nAlqCof		:= (cAliasSFT)->FT_ALIQCOF
Local cEntSai := Iif ("E"$(cAliasSFT)->FT_TIPOMOV, "1", "2")
Local nValICMS := (cAliasSFT)->FT_VALICM
Local cDedbspc := (cAliasSFT)->A2_DEDBSPC
Local cTipoNf  := (cAliasSFT)->FT_TIPO
Local nValDesco := DedPisCof(oC880:getDedbpis(),oC880:getDedbcof(),cEntSai,nValICMS, cDedbspc,cTipoNf, dMVICMDSDT)

oC880:setRelac(cChaveC860)
oC880:setCodItem(cCodProd)
oC880:setiCFOP((cAliasSFT)->FT_CFOP)
oC880:setValItem((cAliasSFT)->FT_VALCONT)
oC880:setiVaDesc(IIf((cAliasSFT)->F4_PISCRED=="5", (cAliasSFT)->FT_TOTAL, (cAliasSFT)->FT_DESCONT + nValDesco))
oC880:setiCSTPis((cAliasSFT)->FT_CSTPIS)
oC880:setiBasPis((cAliasSFT)->FT_BASEPIS)
oC880:setiAlqPis(nAlqPis)
oC880:setiValPis(nVlPis)
oC880:setiCSTCof((cAliasSFT)->FT_CSTCOF)
oC880:setiBasCof((cAliasSFT)->FT_BASECOF)
oC880:setiAlqCof(nAlqCof)
oC880:setiValCof(nVlCof)
oC880:setConta(cConta)
oC880:AddC880()

Return

Function FS007ApCon(dDataDe)
Local cChave	:= ''
Local lConsol	:= .F.

IF	CKR->(MsSeek (xFilial ("CKR")+dTos(dDataDe)))

	cChave := CKR->CKR_FILIAL+DTOS(CKR->CKR_PER)

	Do while !CKR->(Eof()) .And. CKR->CKR_FILIAL+DTOS(CKR->CKR_PER) == cChave
		If CKR->CKR_CONSOL == '1'
			//Se houver ao menos uma linha de apuração consolidada, então a rotina irá considerar somente informações
			//da apuração consolidada.
			lConsol	:= .T.
			Exit
		EndIF

		CKR->(DbSkip())
	EndDo

EndIF

return lConsol

Function AgrpC180(oBlocoC,aReg)

//-------------------------------------------------------------------
//Passa informações para registro C180
//-------------------------------------------------------------------
oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setnModelo(aReg[3])
oBlocoC:setnDtDe(aReg[4])
oBlocoC:setnDtAte(aReg[5])
oBlocoC:setCodItem(aReg[6])
oBlocoC:setNcm(aReg[7])
oBlocoC:setExNcm(aReg[8])
oBlocoC:setValItem(aReg[9])
//processa registro C180
oBlocoC:AddC180()


Return oBlocoC:getGrupo()



Function AgrpC181(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTPis(aReg[3])
oBlocoC:setiCFOP(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiVaDesc(aReg[6])
oBlocoC:setiBasPis(aReg[7])  //Base Normal
oBlocoC:setiAlqPis(aReg[8]) //Alíquota Normal
oBlocoC:setPisQtde(aReg[9]) //Base em quantidade
oBlocoC:setPautPis(aReg[10])//Alíquota em reais
oBlocoC:setiValPis(aReg[11])
oBlocoC:setConta(aReg[12])
oBlocoC:AddC181()

Return

Function AgrpC185(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTCof(aReg[3])
oBlocoC:setiCFOP(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiVaDesc(aReg[6])
oBlocoC:setiBasCof(aReg[7])  //Base Normal
oBlocoC:setiAlqCof(aReg[8]) //Alíquota Normal
oBlocoC:setCofQtde(aReg[9]) //Base em quantidade
oBlocoC:setPautCof(aReg[10])//Alíquota em reais
oBlocoC:setiValCof(aReg[11])
oBlocoC:setConta(aReg[12])
oBlocoC:AddC185()

Return


Function AgrpProcRf(oBloco,aReg,cRelacPai,cReg)


oBloco:setRelac(cRelacPai)
oBloco:setProRef(aReg[3])
oBloco:setTProRef(aReg[4])
oBloco:AddProcRef(cReg)

Return


Function AgrpC190(oBlocoC,aReg)

//-------------------------------------------------------------------
//Passa informações para registro C190
//-------------------------------------------------------------------
oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setnModelo(aReg[3])
oBlocoC:setnDtDe(aReg[4])
oBlocoC:setnDtAte(aReg[5])
oBlocoC:setCodItem(aReg[6])
oBlocoC:setNcm(aReg[7])
oBlocoC:setExNcm(aReg[8])
oBlocoC:setValItem(aReg[9])
//processa registro C190
oBlocoC:AddC190()

Return oBlocoC:getGrupo()



Function AgrpC191(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCnpj(aReg[3])
oBlocoC:setiCSTPis(aReg[4])
oBlocoC:setiCFOP(aReg[5])
oBlocoC:setValItem(aReg[6])
oBlocoC:setiVaDesc(aReg[7])
oBlocoC:setiBasPis(aReg[8])
oBlocoC:setiAlqPis(aReg[9])
oBlocoC:setPisQtde(aReg[10])
oBlocoC:setPautPis(aReg[11])
oBlocoC:setiValPis(aReg[12])
oBlocoC:setConta(aReg[13])
oBlocoC:AddC191()

Return

Function AgrpC195(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCnpj(aReg[3])
oBlocoC:setiCSTCof(aReg[4])
oBlocoC:setiCFOP(aReg[5])
oBlocoC:setValItem(aReg[6])
oBlocoC:setiVaDesc(aReg[7])
oBlocoC:setiBasCof(aReg[8])
oBlocoC:setiAlqCof(aReg[9])
oBlocoC:setCofQtde(aReg[10])
oBlocoC:setPautCof(aReg[11])
oBlocoC:setiValCof(aReg[12])
oBlocoC:setConta(aReg[13])
oBlocoC:AddC195()

Return


Function AgrpC199(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setDocImp(aReg[3])
oBlocoC:setNumImp(aReg[4])
oBlocoC:setVPisImp(aReg[5])
oBlocoC:setVCofImp(aReg[6])
oBlocoC:setDrawBack(aReg[7])
oBlocoC:AddC199()

Return


Function AgrpC380(oBlocoC,aReg)

oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setnModelo(aReg[3])
oBlocoC:setnDtDe(aReg[4])
oBlocoC:setnDtAte(aReg[5])
oBlocoC:setNfIni(aReg[6])
oBlocoC:setnNumNf(aReg[7])
oBlocoC:setValItem(aReg[8])
oBlocoC:setVlCanc(aReg[9])
//processa registro C380
oBlocoC:AddC380()

Return oBlocoC:getGrupo()


Function AgrpC381(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTPis(aReg[3])
oBlocoC:setCodItem(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiBasPis(aReg[6])
oBlocoC:setiAlqPis(aReg[7])
oBlocoC:setPisQtde(aReg[8])
oBlocoC:setPautPis(aReg[9])
oBlocoC:setiValPis(aReg[10])
oBlocoC:setConta(aReg[11])
oBlocoC:AddC381()

Return


Function AgrpC385(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTCof(aReg[3])
oBlocoC:setCodItem(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiBasCof(aReg[6])
oBlocoC:setiAlqCof(aReg[7])
oBlocoC:setCofQtde(aReg[8])
oBlocoC:setPautCof(aReg[9])
oBlocoC:setiValCof(aReg[10])
oBlocoC:setConta(aReg[11])
oBlocoC:AddC385()

Return

Function AgrpC600(oBlocoC,aReg)

oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setnModelo(aReg[3])
oBlocoC:setCodMun(aReg[4])
oBlocoC:setnSerie(aReg[5])
oBlocoC:setClsCon(aReg[7])
oBlocoC:setEmissao(aReg[10])
oBlocoC:setValorNf(aReg[11])
oBlocoC:setnVlDesc(aReg[12])
oBlocoC:setConKwh(Val(aReg[13]))
oBlocoC:setVlForn(aReg[14])
oBlocoC:setVlNTrib(aReg[15])
oBlocoC:setVlTerc(aReg[16])
oBlocoC:setDespesa(aReg[17])
oBlocoC:setBsIcms(aReg[18])
oBlocoC:setVlIcms(aReg[19])
oBlocoC:setNBIcmSt(aReg[20])
oBlocoC:setVlIcmSt(aReg[21])
oBlocoC:setnValPis(aReg[22])
oBlocoC:setnValCof(aReg[23])

//processa registro C600
oBlocoC:AddC600(Val(aReg[9]),Val(aReg[8]))

Return oBlocoC:getGrupo()


Function AgrpC601(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTPis(aReg[3])
oBlocoC:setValItem(aReg[4])
oBlocoC:setiBasPis(aReg[5])
oBlocoC:setiAlqPis(aReg[6])
oBlocoC:setiValPis(aReg[7])
oBlocoC:setConta(aReg[8])
oBlocoC:AddC601()

Return

Function AgrpC605(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTcof(aReg[3])
oBlocoC:setValItem(aReg[4])
oBlocoC:setiBascof(aReg[5])
oBlocoC:setiAlqcof(aReg[6])
oBlocoC:setiValcof(aReg[7])
oBlocoC:setConta(aReg[8])
oBlocoC:AddC605()

Return

Function AgrpC860(oBlocoC,aReg)

oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setNumSAT(aReg[4])
oBlocoC:setEmissao(aReg[5])
oBlocoC:setNfIni(aReg[6])
oBlocoC:setnNumNf(aReg[7])
oBlocoC:AddC860()

Return oBlocoC:getGrupo()

Function AgrpC870(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setCodItem(aReg[3])
oBlocoC:setiCFOP(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiVaDesc(aReg[6])
oBlocoC:setiCSTPis(aReg[7])
oBlocoC:setiBasPis(aReg[8])
oBlocoC:setiAlqPis(aReg[9])
oBlocoC:setiValPis(aReg[10])
oBlocoC:setiCSTCof(aReg[11])
oBlocoC:setiBasCof(aReg[12])
oBlocoC:setiAlqCof(aReg[13])
oBlocoC:setiValCof(aReg[14])
oBlocoC:setConta(aReg[15])
oBlocoC:AddC870()

Return

Function AgrpC880(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setCodItem(aReg[3])
oBlocoC:setiCFOP(aReg[4])
oBlocoC:setValItem(aReg[5])
oBlocoC:setiVaDesc(aReg[6])
oBlocoC:setiCSTPis(aReg[7])
oBlocoC:setiBasPis(aReg[8])
oBlocoC:setiAlqPis(aReg[9])
oBlocoC:setiValPis(aReg[10])
oBlocoC:setiCSTCof(aReg[11])
oBlocoC:setiBasCof(aReg[12])
oBlocoC:setiAlqCof(aReg[13])
oBlocoC:setiValCof(aReg[14])
oBlocoC:setConta(aReg[15])
oBlocoC:AddC880()

Return

Function AgrpD200(oBlocoD,aReg)

oBlocoD:setRelac(SubStr(aReg[1],1,13))
oBlocoD:setnModelo(aReg[3])
oBlocoD:setnSitDoc(aReg[4])
oBlocoD:setnSerie(aReg[5])
oBlocoD:setnNumNf(aReg[7])
oBlocoD:setiCFOP(aReg[9])
oBlocoD:setEmissao(aReg[10])
oBlocoD:setValorNf(aReg[11])
oBlocoD:setnVlDesc(aReg[12])

//processa registro C600
oBlocoD:AddD200(aReg[7],aReg[8])

Return oBlocoD:getGrupo()


Function AgrpD201(oBlocoD,aReg,cRelacPai)

oBlocoD:setRelac(cRelacPai)
oBlocoD:setiCSTPis(aReg[3])
oBlocoD:setValItem(aReg[4])
oBlocoD:setiBasPis(aReg[5])
oBlocoD:setiAlqPis(aReg[6])
oBlocoD:setiValPis(aReg[7])
oBlocoD:setConta(aReg[8])
oBlocoD:AddD201()

Return

Function AgrpD205(oBlocoD,aReg,cRelacPai)

oBlocoD:setRelac(cRelacPai)
oBlocoD:setiCSTCof(aReg[3])
oBlocoD:setValItem(aReg[4])
oBlocoD:setiBasCof(aReg[5])
oBlocoD:setiAlqCof(aReg[6])
oBlocoD:setiValCof(aReg[7])
oBlocoD:setConta(aReg[8])
oBlocoD:AddD205()

Return

Function AgrpD300(oBlocoD,aReg)

oBlocoD:setRelac(SubStr(aReg[1],1,13)) //
oBlocoD:setnModelo(aReg[3]) //
oBlocoD:setnSerie(aReg[4])
oBlocoD:setiCFOP(aReg[8])
oBlocoD:setEntrada(aReg[9])
oBlocoD:setValItem(aReg[10])
oBlocoD:setiAlqPis(aReg[14])
oBlocoD:setiVaDesc(aReg[11])
oBlocoD:setiCSTPis(aReg[12])
oBlocoD:setiBasPis(aReg[13])
oBlocoD:setiAlqPis(aReg[14])
oBlocoD:setiValPis(aReg[15])
oBlocoD:setiCSTCof(aReg[16])
oBlocoD:setiBasCof(aReg[17])
oBlocoD:setiAlqCof(aReg[18])
oBlocoD:setiValCof(aReg[19])
oBlocoD:setConta(aReg[20])

//processa registro C600
oBlocoD:AddD300(aReg[6],aReg[7])

Return oBlocoD:getGrupo()

Function AgrpD350(oBlocoD,aReg)

oBlocoD:setRelac(SubStr(aReg[1],1,13))
oBlocoD:setnModelo(aReg[3])
oBlocoD:setModEcf(aReg[4])
oBlocoD:setSerEcf(aReg[5])
oBlocoD:setEmissao(aReg[6])
oBlocoD:setCro(aReg[7])
oBlocoD:setCrZ(aReg[8])
oBlocoD:setNumCont(aReg[9])
oBlocoD:setVlGrade(aReg[10])
oBlocoD:setVlBrut(aReg[11])
oBlocoD:setiCSTPis(aReg[12])
oBlocoD:setiBasPis(aReg[13])
oBlocoD:setiAlqPis(aReg[14,1])
oBlocoD:setPisQtde(aReg[15])
oBlocoD:setPautPis(aReg[16,1])
oBlocoD:setiValPis(aReg[17])
oBlocoD:setiCSTCof(aReg[18])
oBlocoD:setiBasCof(aReg[19])
oBlocoD:setiAlqCof(aReg[20,1])
oBlocoD:setCofQtde(aReg[21])
oBlocoD:setPautCof(aReg[22,1])
oBlocoD:setiValCof(aReg[23])
oBlocoD:setConta(aReg[24])

//processa registro C600
oBlocoD:AddD350(.T.)

Return oBlocoD:getGrupo()

Function AgrpD600(oBlocoD,aReg)

oBlocoD:setRelac(SubStr(aReg[1],1,13)) //
oBlocoD:setnModelo(aReg[3]) //
oBlocoD:setCodMun(aReg[4])
oBlocoD:setnSerie(aReg[5])
oBlocoD:setTpRec(aReg[7])
oBlocoD:setnDtDe(aReg[9])
oBlocoD:setnDtAte(aReg[10])
oBlocoD:setValorNf(aReg[11])
oBlocoD:setnVlDesc(aReg[12])
oBlocoD:setVlServ(aReg[13])
oBlocoD:setVlNTrib(aReg[14])
oBlocoD:setVlTerc(aReg[15])
oBlocoD:setDespesa(aReg[16])
oBlocoD:setBasIcms(aReg[17])
oBlocoD:setValIcms(aReg[18])
oBlocoD:setnValPis(aReg[19])
oBlocoD:setnValCof(aReg[20])

//processa registro C600
oBlocoD:AddD600(Val(aReg[8]), '')

Return oBlocoD:getGrupo()


Function AgrpD601(oBlocoD,aReg,cRelacPai)

oBlocoD:setRelac(cRelacPai)
oBlocoD:setCodCla(aReg[3])
oBlocoD:setValItem(aReg[4])
oBlocoD:setiVaDesc(aReg[5])
oBlocoD:setiCSTPis(aReg[6])
oBlocoD:setiBasPis(aReg[7])
oBlocoD:setiAlqPis(aReg[8])
oBlocoD:setiValPis(aReg[9])
oBlocoD:setConta(aReg[10])
oBlocoD:AddD601()

Return


Function AgrpD605(oBlocoD,aReg,cRelacPai)

oBlocoD:setRelac(cRelacPai)
oBlocoD:setCodCla(aReg[3])
oBlocoD:setValItem(aReg[4])
oBlocoD:setiVaDesc(aReg[5])
oBlocoD:setiCSTCof(aReg[6])
oBlocoD:setiBasCof(aReg[7])
oBlocoD:setiAlqCof(aReg[8])
oBlocoD:setiValCof(aReg[9])
oBlocoD:setConta(aReg[10])
oBlocoD:AddD605()

Return


Function AgrpF55X(oBlocoF,aReg,cReg)

oBlocoF:setRelac(SubStr(aReg[1],1,13)) //
oBlocoF:setRecAuf(aReg[3]) //
oBlocoF:setiCSTPis(aReg[4])
oBlocoF:setiVaDesc(aReg[5])
oBlocoF:setiBasPis(aReg[6])
oBlocoF:setiAlqPis(aReg[7])
oBlocoF:setiValPis(aReg[8])
oBlocoF:setiCSTCof(aReg[9])
oBlocoF:setiVaDesc(aReg[10])
oBlocoF:setiBasCof(aReg[11])
oBlocoF:setiAlqCof(aReg[12])
oBlocoF:setiValCof(aReg[13])
oBlocoF:setnModelo(aReg[14])
oBlocoF:setiCFOP(aReg[15])
oBlocoF:setConta(aReg[16])
oBlocoF:setDescri(aReg[17])

If cReg == 'F550'

	oBlocoF:AddF550()
ElseIf cReg == 'F560'

	oBlocoF:AddF560()
EndIF

Return oBlocoF:getGrupo()

Function Agrp1900(oBloco1,aReg)

oBloco1:setRelac(SubStr(aReg[1],1,13)) //
oBloco1:setCnpj(aReg[3]) //
oBloco1:setModelo(aReg[4])
oBloco1:setSerie(aReg[5])
oBloco1:setSitDoc(aReg[7])
oBloco1:setVlRec(aReg[8])
oBloco1:setQtdNf(aReg[9])
oBloco1:setiCSTPis(aReg[10])
oBloco1:setiCSTCof(aReg[11])
oBloco1:setiCFOP(aReg[12])
oBloco1:setInfComp(aReg[13])
oBloco1:setConta(aReg[14])

oBloco1:Add1900()

Return

Function AgrpC490(oBlocoC,aReg)

oBlocoC:setRelac(SubStr(aReg[1],1,13)) //
oBlocoC:setnDtDe(aReg[3]) //
oBlocoC:setnDtAte(aReg[4])
oBlocoC:setnModelo(aReg[5])

oBlocoC:AddC490()

Return oBlocoC:getGrupo()


Function AgrpC491(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setCodItem(aReg[3])
oBlocoC:setiCSTPis(aReg[4])
oBlocoC:setiCFOP(aReg[5])
oBlocoC:setValItem(aReg[6])
oBlocoC:setiBasPis(aReg[7])
oBlocoC:setiAlqPis(aReg[8][1])
oBlocoC:setPisQtde(aReg[9][1])
oBlocoC:setPautPis(aReg[10][1])
oBlocoC:setiValPis(aReg[11])
oBlocoC:setConta(aReg[12])
oBlocoC:AddC491()

Return

Function AgrpC495(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setCodItem(aReg[3])
oBlocoC:setiCSTCof(aReg[4])
oBlocoC:setiCFOP(aReg[5])
oBlocoC:setValItem(aReg[6])
oBlocoC:setiBasCof(aReg[7])
oBlocoC:setiAlqCof(aReg[8][1])
oBlocoC:setCofQtde(aReg[9][1])
oBlocoC:setPautcof(aReg[10][1])
oBlocoC:setiValCof(aReg[11])
oBlocoC:setConta(aReg[12])
oBlocoC:AddC495()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Agrp1011()
Função para agrupar informações do registro 1011 no processamento via
Multithread

@author Erick G. Dias
@since 12/11/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function Agrp1011(oBloco1,aReg,cRelacPai)

//Adiciona informações da nota
oBloco1:setRelac(cRelacPai)
oBloco1:setRegRef(aReg[3])
oBloco1:setChvNfe(aReg[4])
oBloco1:setCodPart(aReg[5])
oBloco1:setCodItem(aReg[6])
oBloco1:setEmissao(aReg[7])
oBloco1:setValItem(aReg[8])
oBloco1:setiCSTPis(aReg[9])
oBloco1:setiAlqPis(aReg[11][1])
oBloco1:setiCSTCof(aReg[13])
oBloco1:setiAlqCof(aReg[15][1])
oBloco1:setConta(aReg[25])
oBloco1:setiCCusto(aReg[26])
oBloco1:setnInfCmp(aReg[27])
oBloco1:setCstPisS(aReg[17]) //Campo Obrigatorio CST Pis Susp
oBloco1:setCstCofS(aReg[21]) //Campo Obrigatorio CST Cof Susp

//Primeiro adiciona informações do PIS
oBloco1:setTrib("7")
oBloco1:setiBasPis(aReg[10][1])
oBloco1:setiValPis(aReg[12])
oBloco1:setBasPisS(aReg[18][1])
oBloco1:setAlqPisS(aReg[19][1])
oBloco1:setValPisS(aReg[20])
oBloco1:Add1011()

//Agora adiciona informações da COFINS
oBloco1:setTrib("8")
oBloco1:setiBasCof(aReg[14][1])
oBloco1:setiValCof(aReg[16])
oBloco1:setBasCofS(aReg[22][1])
oBloco1:setAlqCofS(aReg[23][1])
oBloco1:setValCofS(aReg[24])
oBloco1:Add1011()

Return

Function AgrpC400(oBlocoC,aReg)

oBlocoC:setRelac(SubStr(aReg[1],1,13)) 
oBlocoC:setModEcf(aReg[4]) 
oBlocoC:setSerEcf(aReg[5])
oBlocoC:setNumEcf(aReg[6])

oBlocoC:AddC400()

Return oBlocoC:getGrupo()


Function AgrpC405(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai) 
oBlocoC:setDtRedZ(aReg[3]) 
oBlocoC:setCro(aReg[4])
oBlocoC:setCrZ(aReg[5])
oBlocoC:setNumCont(aReg[6])
oBlocoC:setVlGrade(aReg[7])
oBlocoC:setVlBrut(aReg[8])

oBlocoC:AddC405()

Return oBlocoC:getGrupo()


Function AgrpC481(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTPis(aReg[3])
oBlocoC:setValItem(aReg[4])
oBlocoC:setiBasPis(aReg[5])
oBlocoC:setiAlqPis(aReg[6][1])
oBlocoC:setPisQtde(aReg[7][1])
oBlocoC:setPautPis(aReg[8][1])
oBlocoC:setiValPis(aReg[9])
oBlocoC:setCodItem(aReg[10])
oBlocoC:setConta(aReg[11])

oBlocoC:AddC481()

Return

Function AgrpC485(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCSTCof(aReg[3])
oBlocoC:setValItem(aReg[4])
oBlocoC:setiBasCof(aReg[5])
oBlocoC:setiAlqCof(aReg[6][1])
oBlocoC:setCofQtde(aReg[7][1])
oBlocoC:setPautCof(aReg[8][1])
oBlocoC:setiValCof(aReg[9])
oBlocoC:setCodItem(aReg[10])
oBlocoC:setConta(aReg[11])

oBlocoC:AddC485()

Return


Function AgruA100(oBlocoA,aReg)

oBlocoA:setRelac((SubStr(aReg[1],1,13)))
oBlocoA:setIndOper(aReg[3])
oBlocoA:setIndEmit(aReg[4])
oBlocoA:setCodPart(aReg[5])
oBlocoA:setnSitDoc(aReg[6])
oBlocoA:setnSerie(aReg[7])
oBlocoA:setnNumNf(aReg[9])
oBlocoA:setChvNfe(aReg[10])
oBlocoA:setEmissao(aReg[11])
oBlocoA:setExec(aReg[12])
oBlocoA:setValorNf(aReg[13])
oBlocoA:setIndPgto(aReg[14])
oBlocoA:setnVlDesc(aReg[15])
oBlocoA:setnBasPis(aReg[16])
oBlocoA:setnValPis(aReg[17])
oBlocoA:setnBasCof(aReg[18])
oBlocoA:setnValCof(aReg[19])
oBlocoA:setPisRet(aReg[20])
oBlocoA:setCofRet(aReg[21])
oBlocoA:setValIss(aReg[22])
oBlocoA:AddA100(.T.)

Return oBlocoA:getGrupo()

Function AgruA110(oBlocoA,aReg,cRelacPai)

oBlocoA:setRelac(cRelacPai)
oBlocoA:setCodInfC(aReg[3])
oBlocoA:setDescri(aReg[4])
//Adiciona registro
oBlocoA:AddA110()

Return

Function AgruA120(oBlocoA,aReg,cRelacPai)

oBlocoA:setRelac(cRelacPai)
oBlocoA:setVImport(aReg[3])
oBlocoA:setBPisImp(aReg[4])
oBlocoA:setVPisImp(aReg[5])
oBlocoA:setDtPgPis(aReg[6])
oBlocoA:setBCofImp(aReg[7])
oBlocoA:setVCofImp(aReg[8])
oBlocoA:setDtPgCof(aReg[9])
oBlocoA:setLocal(aReg[10])
//Adiciona novo registro
oBlocoA:AddA120()

Return

Function AgruA170(oBlocoA,aReg,cRelacPai,nContA170)

//Passa informnações para objeto para geração do A1170
oBlocoA:setRelac(cRelacPai)
oBlocoA:setNumitem(cvaltochar(nContA170))
oBlocoA:setCodItem(aReg[4])
oBlocoA:setDescri(aReg[5])
oBlocoA:setValItem(aReg[6])
oBlocoA:setiVaDesc(aReg[7])
oBlocoA:setiCodBcc(aReg[8])
oBlocoA:setOriCrd(aReg[9])
oBlocoA:setiCSTPis(aReg[10])
oBlocoA:setiBasPis(aReg[11])
oBlocoA:setiAlqPis(aReg[12])
oBlocoA:setiValPis(aReg[13])
oBlocoA:setiCSTCof(aReg[14])
oBlocoA:setiBasCof(aReg[15])
oBlocoA:setiAlqCof(aReg[16])
oBlocoA:setiValCof(aReg[17])
oBlocoA:setConta(aReg[18])
oBlocoA:setiCCusto(aReg[19])
oBlocoA:AddA170(.F.) 

Return

Function AgruC100(oBlocoC,aReg)
//-------------------------------------------------------------------
//Passa informações do cabeçalho do C100
//-------------------------------------------------------------------
oBlocoC:setRelac(SubStr(aReg[1],1,13))
oBlocoC:setIndOper(aReg[3])
oBlocoC:setIndEmit(aReg[4])
oBlocoC:setCodPart(aReg[5])
oBlocoC:setnModelo(aReg[6])
oBlocoC:setnSitDoc(aReg[7])
oBlocoC:setnSerie(aReg[8])
oBlocoC:setnNumNf(aReg[9])
oBlocoC:setChvNfe(aReg[10])
oBlocoC:setEmissao(aReg[11])
oBlocoC:setEntrada(aReg[12])
oBlocoC:setValorNf(aReg[13])
oBlocoC:setIndPgto(aReg[14])
oBlocoC:setnVlDesc(aReg[15])
oBlocoC:setAbatim( aReg[16]) 
oBlocoC:setVlMerc(aReg[17]) 
oBlocoC:setTpFrt(aReg[18]) 
oBlocoC:setVlFrete(aReg[19]) 
oBlocoC:setSeguro(aReg[20]) 
oBlocoC:setDespesa(aReg[21]) 
oBlocoC:setBsIcms(aReg[22]) 
oBlocoC:setVlIcms(aReg[23]) 
oBlocoC:setNBIcmSt(aReg[24]) 
oBlocoC:setVlIcmSt(aReg[25]) 
oBlocoC:setIPI(aReg[26]) 
oBlocoC:setnValPis(aReg[27])
oBlocoC:setnValCof(aReg[28])
oBlocoC:setPisSt(aReg[29])
oBlocoC:setCofSt(aReg[30])
oBlocoC:AddC100(.T.)

Return oBlocoC:getGrupo()

Function AgruC110(oBlocoC,aReg,cRelacPai)

oBlocoC:setRelac(cRelacPai)
oBlocoC:setCodInfC(aReg[3])
oBlocoC:setDescri(aReg[4]) 
oBlocoC:AddC110() 

Return

Function AgruC120(oBlocoC,aReg,cRelacPai)
oBlocoC:setRelac(cRelacPai)
oBlocoC:setDocImp(aReg[3])
oBlocoC:setNumImp(aReg[4]) 
oBlocoC:setVPisImp(aReg[5]) 
oBlocoC:setVCofImp(aReg[6]) 
oBlocoC:setDrawBack(aReg[7])
oBlocoC:AddC120() 
Return

Function AgruC170(oBlocoC,aReg,cRelacPai,nContC170)

//Passa informnações para objeto para geração do A170
oBlocoC:setRelac(cRelacPai)
oBlocoC:setNumitem(cvaltochar(nContC170))
oBlocoC:setCodItem(aReg[4])
oBlocoC:setDescri(aReg[5])
oBlocoC:setiQtde(aReg[6][1])
oBlocoC:setUnMed(aReg[7])
oBlocoC:setValItem(aReg[8])
oBlocoC:setiVaDesc(aReg[9])
oBlocoC:setIndMvto(aReg[10])
oBlocoC:setCSTICMS(aReg[11])
oBlocoC:setiCFOP(aReg[12])
oBlocoC:setNatOper(aReg[13])
oBlocoC:setBasIcms(aReg[14])
oBlocoC:setAlqIcms(aReg[15])
oBlocoC:setICMSDC(aReg[16])
oBlocoC:setBsIcmSt(aReg[17])
oBlocoC:setAlqcmSt(aReg[18])
oBlocoC:setICMSST(aReg[19])
oBlocoC:setIndIpi(aReg[20])
oBlocoC:setCstIpi(aReg[21])
oBlocoC:setEnqIpi(aReg[22])
oBlocoC:setBasIpi(aReg[23])
oBlocoC:setAlqIpi(aReg[24])
oBlocoC:setIpiDC(aReg[25])
oBlocoC:setiCSTPis(aReg[26])
oBlocoC:setiBasPis(aReg[27])
oBlocoC:setiAlqPis(aReg[28][1])
oBlocoC:setPisQtde(aReg[29][1])
oBlocoC:setPautPis(aReg[30][1])
oBlocoC:setiValPis(aReg[31])
oBlocoC:setiCSTCof(aReg[32])
oBlocoC:setiBasCof(aReg[33])
oBlocoC:setiAlqCof(aReg[34][1])
oBlocoC:setCofQtde(aReg[35][1])
oBlocoC:setPautcof(aReg[36][1])
oBlocoC:setiValCof(aReg[37])
oBlocoC:setConta(aReg[38])
oBlocoC:AddC170(.F.) 
Return 

Function AgruC175(oBlocoC,aReg,cRelacPai)
oBlocoC:setRelac(cRelacPai)
oBlocoC:setiCFOP(aReg[3])
oBlocoC:setValItem(aReg[4])	
oBlocoC:setiVaDesc(aReg[5])
oBlocoC:setiCSTPis(aReg[6])	
oBlocoC:setiBasPis(aReg[7])
oBlocoC:setiAlqPis(aReg[8])	
oBlocoC:setPisQtde(aReg[9])	
oBlocoC:setPautPis(aReg[10])
oBlocoC:setiValPis(aReg[11])
oBlocoC:setiCSTCof(aReg[12])
oBlocoC:setiBasCof(aReg[13])
oBlocoC:setiAlqCof(aReg[14])
oBlocoC:setCofQtde(aReg[15])
oBlocoC:setPautcof(aReg[16])
oBlocoC:setiValCof(aReg[17])
oBlocoC:setConta(aReg[18])	
oBlocoC:setInfComp(aReg[19])
oBlocoC:AddC175()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF07
@description Função que irá buscar processo referenciado gravado na tabela F07
			   das operações do regime de caixa. Isso é necessário pois todas
			   as movimentações foram gravadas pela apuração, e estão agrupadas,
			   por este motivo não tem como buscar as tabelas CDG e CCF, estas informações
			   são possíveis somente na apuração, por este motivo estão
			   gravadas na tabela F07.

@author Erick G. Dias
@since 24/09/2015
@version 11.90
/*/
//-------------------------------------------------------------------
Static Function ProcF07(cId, dDataDe,lPauta,cRelacPai,oBlocoF,oBloco1, lTabCie, cConta)

Local cChave		:= xFilial("F07")+dTos(dDataDe)+cId
Local cChaveCIE		:= ""
Local cChave1010	:= ""

If lTabCie //Somente vai processar caso a tabela CIE exista, pois antes disso os campos não haviam campos suficiente na F07 para relacionar corretamente com a CCF. Isso ocorreu quando criaram itens na tabela CCF.

	DbSelectArea ('CIE')
	CIE->(DbSetOrder(2))

	IF F07->(MsSeek (cChave))

		//F07_FILIAL+DTOS(F07_PER)+F07_ID+F07_INDPRO+F07_NUMPRO
		Do while !F07->(Eof()) .And. F07->F07_FILIAL+DTOS(F07->F07_PER)+F07->F07_ID==cChave

			If CCF->(MsSeek (xFilial ("CCF")+F07->F07_NUMPRO+F07->F07_INDPRO+F07->F07_INDAUT+F07->F07_IDITEM))

				If CCF->CCF_TPCOMP == '1' //Complemento do processo referenciado - Judicial
					Proc1010('1001000000001', oBloco1, 'CCF')
					cChave1010	:= oBloco1:getGrupo()

					//Posiciona a tabela CIE
					//Processa informações da exigibilidade suspensa para registro 1011
					cChaveCIE		:= xFilial("CIE")+dTos(dDataDe)+cId+CCF->CCF_NUMERO+CCF->CCF_TIPO+CCF->CCF_INDAUT+CCF->CCF_IDITEM+CCF->CCF_NATJU

					If Year(dDataDe) >= 2020 .AND. CCF->CCF_TRIB $ "7|8|" .AND. CCF->CCF_NATJU $ "12/13/14/15/16/17/19" .AND. CIE->(DBSEEK(cChaveCIE))

						//Aqui Busco as informações da CIE para enviar para classe do bloco 1
						oBloco1:setRelac(cChave1010)
						oBloco1:setRegRef("F500")
						oBloco1:setEmissao(CIE->CIE_DTOPER)
						oBloco1:setValItem(CIE->CIE_VLOPER)
						oBloco1:setConta(cConta)
						oBloco1:setTrib(CCF->CCF_TRIB)
						oBloco1:setiCSTPis(CIE->CIE_CPIS)
						oBloco1:setiCSTCof(CIE->CIE_CCOF)
						oBloco1:setiAlqCof(CIE->CIE_ACOF)
						oBloco1:setiAlqPis(CIE->CIE_APIS)

						If CCF->CCF_TRIB == "7"
							//Valores de PIS, já que o processo está com tributo PIS
							oBloco1:setiBasPis(CIE->CIE_BPIS)
							oBloco1:setiValPis(CIE->CIE_VPIS)
							oBloco1:setCstPisS(CIE->CIE_CPISSU)
							oBloco1:setBasPisS(CIE->CIE_BPISSU)
							oBloco1:setAlqPisS(CIE->CIE_APISSU)
							oBloco1:setValPisS(CIE->CIE_VPISSU)
							oBloco1:setCodRec(CIE->CIE_CODPIS)
						ElseIF CCF->CCF_TRIB == "8"
							//Valores de COFINS, já que o processo está com tributo COFINS
							oBloco1:setiBasCof(CIE->CIE_BCOF)
							oBloco1:setiValCof(CIE->CIE_VCOF)
							oBloco1:setCstCofS(CIE->CIE_CCOFSU)
							oBloco1:setBasCofS(CIE->CIE_BCOFSU)
							oBloco1:setAlqCofS(CIE->CIE_ACOFSU)
							oBloco1:setValCofS(CIE->CIE_VCOFSU)
							oBloco1:setCodRec(CIE->CIE_CODCOF)
						EndIF

						oBloco1:Add1011()

					EndIF

				ElseIf CCF->CCF_TPCOMP == '2' //Complemento do processo referenciado - Administrativo
					Proc1020('1001000000001', oBloco1, 'CCF')
				EndIF

			EndIF

			IF !Empty(F07->F07_NUMPRO) .AND. !Empty(F07->F07_INDPRO)

				ProcRefC(cRelacPai, oBlocoF, Iif(lPauta,'F519','F509'), F07->F07_NUMPRO, F07->F07_INDPRO )

			EndIF

			F07->(DbSkip())
		Enddo

	EndIF
EndiF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ProcSerie
@description Função que irá alterar serie do documento
Tratamento para Loja Cem que importa notas com mesma chave (numero, serie, cliente, fornecedor)
TSF altera serie na imporação acresentando letra na Serie do documento
Com serie alterada ocorre erro de chave nos arquivos SPED Fiscal e Contribuições

@author Rafael S Oliveira
@since 15/04/2016
/*/
//-------------------------------------------------------------------
Static Function ProcSerie(cSerie, cModelo, cEFDSerie)

//Local cEFDSerie := SuperGetMV("MV_EFDSERI",.F.,"") //Informar series de documentos de prestacao de servicos que devem ser gerados em branco no EFD.
Local cNovSerie := ""

Default cModelo := ""

If Empty(cModelo) .And. AllTrim(cSerie) $ cEFDSerie
	cSerie := ""
EndIf

If lSPDFIS11
	cNovSerie := ExecBlock("SPDFIS11",.F.,.F.,{cSerie,cModelo})
	If ValType(cNovSerie)== "C"
		cSerie := cNovSerie
	Endif
Endif

Return cSerie

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcF800
@description Função para geração do registro F800,  CRÉDITOS DECORRENTES DE EVENTOS DE INCORPORAÇÃO, FUSÃO
E CISÃO que está gravado na tabela F0X.
@param cChaveF010,String,Relação com registro pai F010
@param oF800,Objeto,Objeto da classe EFDCBLOCOF
@param cAliasF0X,Query,Query realizada na tabela F0X
@author Henriq	ue Pereira
@since 14/06/2016
@version 11.90
/*/
//-------------------------------------------------------------------
Function ProcF800(cChaveF010, oF800, cAliasF0X)

oF800:setRelac(cChaveF010)
oF800:setNatEven((cAliasF0X)->F0X_NATEVE)
oF800:setDtEven((cAliasF0X)->F0X_DTEVEN)
oF800:setSuCnpj((cAliasF0X)->F0X_SUCNPJ)
oF800:setPeriod((cAliasF0X)->F0X_PERIOD)
oF800:setCodCre((cAliasF0X)->F0X_CODCRE)
oF800:setValPis((cAliasF0X)->F0X_VALPIS)
oF800:setValCof((cAliasF0X)->F0X_VALCOF)
oF800:setPcCisa((cAliasF0X)->F0X_PCCISA)
//Processa registro F700
oF800:AddF800()

Return
