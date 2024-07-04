#INCLUDE "TOTVS.CH" 
#INCLUDE "PONM440.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PONM440  ºAutor  ³Leandro Drumond     º Data ³  07/01/2016 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geração de pré-abonos baseado nos treinamentos (SIGATRM)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAPON                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºAlterado Por³ Data   ³      Alteracao                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º            ³        ³                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 

Function PONM440()

Local aArea			:= GetArea()
Local bProcesso 	:= { |oSelf| Pnm440Processa(oSelf) }
Local cCadastro 	:= STR0001 //"Integração Ponto Eletrônico X Treinamento"
Local cDescricao 	:= STR0002 // "Este programa gera pré-abonos para os funcionários em treinamento com base nas informações do módulo SIGATRM." 
         
Private aLog		:= {}
Private aTitle		:= {}

PRIVATE aFldRot 	 := {'RA_NOME'}
PRIVATE aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
PRIVATE lOfuscaNom 	:= .F. //RA_NOME
PRIVATE aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

Begin Sequence

	Pergunte("PNM440",.F.)
	
	tNewProcess():New( "PNM440" , cCadastro , bProcesso , cDescricao , "PNM440", , , , ,.T.,.T.  )  
	
	If !Empty(aLog)
		fMakeLog(aLog,aTitle,,,STR0001,STR0003,"M","P",,.F.)
	EndIf
	
End Sequence

RestArea( aArea )

Return Nil

Static Function Pnm440Processa(oSelf)
Local cWhere	:= ""
Local cCat		:= ""
Local cCodAbo	:= ""
Local cAliasTMP	:= ""
Local cAliasQry	:= ""
Local cJoin		:= ""
Local cFilMat	:= ""
Local nPos		:= 0
Local nRegProc	:= 0
Local lBaixados	:= .F.
Local dDataDe	:= CtoD("")
Local dDataAte	:= CtoD("")
Local dPerIni	:= Ctod("")
Local dPerFim	:= CtoD("")
Local dPerAux	:= CtoD("")

Pergunte("PNM400",.F.)

dDataDe		:= MV_PAR07
dDataAte	:= MV_PAR08
lBaixados 	:= MV_PAR09 == 1
cCodAbo		:= MV_PAR10

If Empty(cCodAbo)
	MsgInfo(STR0004) //"Necessário informar o código de pré-abono que será utilizado."
	Return Nil
EndIf

DbSelectArea("SP6")
If !DbSeek(xFilial("SP6")+cCodAbo) .or. SP6->P6_PREABO <> "S"
	MsgInfo(STR0005) //"Código de pré-abono inválido ou inexistente."
	Return Nil
EndIf

GetPonMesDat( @dPerIni , @dPerFim) //Retorna data inicial e final do MV_PONMES

If dDataDe > dDataAte
	MsgInfo(STR0006) //"Data Inicial deve ser maior ou igual a data final"
	Return Nil
EndIf

If !(dDataDe >= dPerIni .and. dDataAte <= dPerFim)
	MsgInfo(STR0007 + Dtoc(dPerIni) + " - " + DtoC(dPerFim)) //"Data Inicial e Final devem estar dentro do período definido no parâmetro MV_PONMES. Período aberto no ponto: "
	Return Nil
EndIf

MakeSqlExpr("PNM440")

If !Empty(MV_PAR01)	//RA_FILIAL
	cWhere += MV_PAR01
EndIf  

If !Empty(MV_PAR02)	//RA_MAT
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += MV_PAR02
EndIf  

If !Empty(MV_PAR03) //RA_NOME
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += MV_PAR03
EndIf

If !Empty(MV_PAR04) //RA_CC
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += MV_PAR04
EndIf 

For nPos := 1 To Len(MV_PAR06)
	If SubStr(MV_PAR06,nPos,1) <> "*" .And. !Empty(SubStr(MV_PAR06,nPos,1))
		cCat += "'" + SubStr(MV_PAR06,nPos,1) + "',"
	EndIf
Next nPos

If Len(cCat)>1
	cCat := SubStr(cCat,1,Len(cCat)-1)
	cWhere += Iif(!Empty(cWhere)," AND ","")
	cWhere += " RA_CATFUNC IN("+cCat+") "
EndIf

If !Empty(MV_PAR05) //RA1_CURSO
	cWhere += Iif(!Empty(cWhere)," AND ","")
	If lBaixados
		cWhere += StrTran(MV_PAR05,"RA1_CURSO","RA4_CURSO")
	Else
		cWhere += StrTran(MV_PAR05,"RA1_CURSO","RA2_CURSO")
	EndIf
EndIf

If !Empty(cWhere)
	cWhere += " AND "
ENDIF

cWhere := "%" + cWhere + "%"


cAliasTMP := GetNextAlias()
cAliasQry := GetNextAlias()

DbSelectArea("RF0")
DbSetOrder(1) //RF0_FILIAL+RF0_MAT+DTOS(RF0_DTPREI)+STR(RF0_HORINI,5,2)

If lBaixados

	BeginSql alias cAliasTMP
		SELECT COUNT(DISTINCT(RA_FILIAL || RA_MAT)) as NROREG 
		FROM %table:SRA% SRA
		INNER JOIN %table:RA4% RA4 ON RA4_FILIAL = RA_FILIAL AND RA4_MAT = RA_MAT AND RA4.%notDel%
		WHERE  %exp:cWhere% ( (RA4_DATAIN BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%) OR ((RA4_DATAIN BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%))) AND SRA.%notDel%
	EndSql
	
	While (cAliasTMP)->( !Eof() )
		nRegProc += (cAliasTMP)->(NROREG)
		(cAliasTMP)->( dbSkip() )
	EndDo
	
	(cAliasTMP)->( dbCloseArea() )

	BeginSql alias cAliasQry
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA4_CURSO,RA4_DATAIN, RA4_DATAFI
		FROM %table:SRA% SRA
		INNER JOIN %table:RA4% RA4 ON RA4_FILIAL = RA_FILIAL AND RA4_MAT = RA_MAT AND RA4.%notDel%
		WHERE  %exp:cWhere% ( (RA4_DATAIN BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%) OR ((RA4_DATAFI BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%))) AND SRA.%notDel%
		ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	EndSql
Else

	cJoin := "%"
	cJoin += FWJoinFilial( "RA3", "RA2" )
	cJoin += "%"

	BeginSql alias cAliasTMP
		SELECT COUNT(DISTINCT(RA_FILIAL || RA_MAT)) as NROREG 
		FROM %table:SRA% SRA
		INNER JOIN %table:RA3% RA3 ON RA3_FILIAL = RA_FILIAL AND RA3_MAT = RA_MAT AND RA3.%notDel%
		INNER JOIN %table:RA2% RA2 ON %exp:cJoin% AND RA2_CURSO = RA3_CURSO AND RA2_CALEND = RA3_CALEND AND RA2.%notDel% 
		WHERE  %exp:cWhere%  ( (RA2_DATAIN BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%) OR ((RA2_DATAFI BETWEEN %exp:DtoS(dDataAte)% AND %exp:DtoS(dDataAte)%))) AND SRA.%notDel%
	EndSql
	
	While (cAliasTMP)->( !Eof() )
		nRegProc += (cAliasTMP)->(NROREG)
		(cAliasTMP)->( dbSkip() )
	EndDo
	
	(cAliasTMP)->( dbCloseArea() )

	BeginSql alias cAliasQry
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA2_CURSO RA4_CURSO ,RA2_DATAIN RA4_DATAIN, RA2_DATAFI RA4_DATAFI
		FROM %table:SRA% SRA
		INNER JOIN %table:RA3% RA3 ON RA3_FILIAL = RA_FILIAL AND RA3_MAT = RA_MAT AND RA3.%notDel%
		INNER JOIN %table:RA2% RA2 ON %exp:cJoin% AND RA2_CURSO = RA3_CURSO AND RA2_CALEND = RA3_CALEND AND RA2.%notDel% 
		WHERE  %exp:cWhere%  ( (RA2_DATAIN BETWEEN %exp:DtoS(dDataDe)% AND %exp:DtoS(dDataAte)%) OR ((RA2_DATAFI BETWEEN %exp:DtoS(dDataAte)% AND %exp:DtoS(dDataAte)%))) AND SRA.%notDel%
		ORDER BY SRA.RA_FILIAL, SRA.RA_MAT 
	EndSql

EndIf

//Inicia a regua de processamento
oSelf:SaveLog(STR0008 + " - " + STR0009 ) // "Integração com Treinamento" ### "Inicío do Processamento"
oSelf:SetRegua1(nRegProc)

If nRegProc > 0
	aAdd( aTitle, STR0010 ) //"Funcionários Processados"
	aAdd( aLog	, {} )
Else
	aAdd( aTitle, STR0012 ) //"Log da Integração"
	aAdd( aLog	, {} )
	aAdd( aLog[Len(aLog)], STR0011) //"Nenhum registro processado."
EndIf

While (cAliasQry)->(!Eof())
	If oSelf:lEnd 
		Break 
	EndIf
	
	If cFilMat <> (cAliasQry)->(RA_FILIAL + RA_MAT)
		oSelf:IncRegua1( STR0013 + (cAliasQry)->RA_FILIAL + " - " + (cAliasQry)->RA_MAT + iif(lOfuscaNom ,''," - " + (cAliasQry)->RA_NOME) ) //"Integrando funcionário: "
		cFilMat := (cAliasQry)->(RA_FILIAL + RA_MAT)
	EndIf
	
	dPerIni := Max(StoD((cAliasQry)->RA4_DATAIN),dDataDe)
	dPerFim := Min(StoD((cAliasQry)->RA4_DATAFI),dDataAte)
	dPerAux := dPerIni
    	
	If !RF0->(DbSeek((cAliasQry)->(RA_FILIAL + RA_MAT + DtoS(dPerIni)))) //Já existe pré-abono gravado
		If dPerFim > dPerIni
			dPerAux++
			While dPerAux <= dPerFim
				If RF0->(DbSeek((cAliasQry)->(RA_FILIAL + RA_MAT + DtoS(dPerAux)))) //Se encontrar pré-abono com o mesmo código em periodo igual ao que esta gravando 
					If RF0->RF0_CODABO == cCodAbo
						If RF0->RF0_DTPREF > dPerFim //Se o final do pré-abono for maior que o periodo atual, altera data inicial para iniciar após o abono que esta gravando
							RecLock("RF0",.F.)
							RF0->RF0_DTPREI := dPerFim + 1
							MsUnLock()
							dPerAux := dPerFim + 1
						Else //do contrário, exclui abono,para que o novo seja criado
							RecLock("RF0",.F.)
							DbDelete()
							MsUnLock()
						EndIf
					EndIf
				EndIf
				dPerAux++
			EndDo
		EndIf 
		RecLock("RF0",.T.)
		RF0->RF0_FILIAL	 := (cAliasQry)->RA_FILIAL
		RF0->RF0_MAT	 := (cAliasQry)->RA_MAT
		RF0->RF0_DTPREI	 := dPerIni
		RF0->RF0_DTPREF	 := dPerFim
		RF0->RF0_CODABO	 := cCodAbo
		RF0->RF0_HORTAB	 := "S"
		RF0->RF0_ABONA	 := "N"
		RF0->RF0_USUAR	 := cUserName
		RF0->RF0_FLAG	 := "I"
		MsUnLock()
		If Len(aLog[1]) == 0
			aAdd( aLog[1], STR0015 + Space(TamSX3("RA_FILIAL")[1] - 4) + STR0016 + "   " + STR0017 + Space(TamSX3("RA_NOME")[1]-2) + STR0018 + "  " + STR0019 )
		EndIf
		aAdd( aLog[1], (cAliasQry)->RA_FILIAL + "  " + (cAliasQry)->RA_MAT + Space(6) + If(lOfuscaNom,Replicate('*',TamSX3("RA_NOME")[1]),(cAliasQry)->RA_NOME) + "  " + DtoC(dPerIni) + "    " + DtoC(dPerFim))
	Else
		If Len(aTiTle) <= 1
			aAdd( aTitle, STR0014 )
			Aadd( aLog	, {} )
			aAdd( aLog[2], STR0015 + Space(TamSX3("RA_FILIAL")[1] - 4) + STR0016 + "   " + STR0017 + Space(TamSX3("RA_NOME")[1]-2) + STR0018 + "  " + STR0020 )
		EndIf
		aAdd( aLog[2], (cAliasQry)->RA_FILIAL + "  " + (cAliasQry)->RA_MAT + Space(6) + If(lOfuscaNom,Replicate('*',TamSX3("RA_NOME")[1]),(cAliasQry)->RA_NOME) + "  " + DtoC(dPerIni) + "    " + STR0021)
	EndIf
	
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return Nil