#include "VDFM040.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} VDFM040
Inclusão na Folha de Pagamento.
@sample 	VDFM040()
@author	    Nivia Ferreira
@since		12/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDFM040(aDados,cNovaFil)
Local cPendencia	:= .F.
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
Private cNewFil := ''
Private aDadosAut := {}

Default cNovaFil := ''
Default	aDados := {}

If IsBlind()
	cNewFil := cNovaFil
	aDadosAut := aDados
Else
	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf
Endif

If FwFldGet( 'REY_SITUAC' ) == '3'
	Help(,,'Help',,STR0002,1,0) //'Candidato solicitou desistência temporária.'
	Return()
Endif

If FwFldGet( 'REY_SITUAC' ) == '4'
	Help(,,'Help',,STR0003,1,0) //'Candidato solicitou desistência definitiva.'
	Return()
Endif

If !Empty(FwFldGet( 'REY_EXONER' )) //'Foi publicado a exoneração para esse candidato.'
	Help(,,'Help',,STR0004,1,0)
   Return()
Endif

If Empty(FwFldGet( 'REY_NOMEAC' ))
		Help(,,'Help',,STR0005,1,0) //'Não foi publicado a nomeação para esse candidato.'
	Return()
Endif

dbSelectArea("REY")
dbSetOrder(4)
dbSeek(FwxFilial("REY")+FwFldGet('REY_CPF')+FwFldGet('REZ_CODCON')+FwFldGet('REZ_FILFUN')+FwFldGet('REZ_CODFUN'))

If REY->REY_SITUAC == '5'
		Help(,,'Help',,STR0001,1,0) //'Servidor ja Contratado.'
	Return()
Endif

cQuery  := "SELECT REZ_DTENTR "
cQuery  += " FROM " + RetSqlName( 'REZ' )
cQuery  += " WHERE D_E_L_E_T_ = ' ' "
cQuery  += " AND  REZ_CPF='"+    FwFldGet( 'REZ_CPF' )   +"'"
cQuery  += " AND  REZ_CODCON='"+ FwFldGet( 'REZ_CODCON' )+"'"
cQuery  += " AND  REZ_FILFUN='"+ FwFldGet( 'REZ_FILFUN' )+"'"
cQuery  += " AND  REZ_CODFUN='"+ FwFldGet( 'REZ_CODFUN' )+"'"
cQuery  += " AND  REZ_DTENTR=' '"
dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery),"TRB", .F., .T.)
dbSelectArea("TRB")
If !TRB->( EOF() )
   cPendencia := .T.
Endif
TRB->( dbCloseArea() )

dbSelectArea('SQG')
If cPendencia==.T.
	If !IsBlind() .and. MsgYesNo(STR0006) //'Não foram entregues todos os documentos. Deseja incluir na folha?')
		VDF040Cnv()
   Endif
Else
	VDF040Cnv()
Endif

Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF040Cnv
Transforma Curriculo em Funcionario.
@sample 	VDF040Cnv()
@author	    Nivia Ferreira
@since		12/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF040Cnv()
Local aArea   	:= GetArea()
Local cChave    := ''
Local cCmd      := ''
Local cFilServ	:= Space( TamSX3("RA_FILIAL")[1] )
Local cFilBkp	:= cFilAnt //guarda a filial original
Local nInicial  := 0
Local nFinal    := 0
Local nMeio     := 0
Local I         := 0
Local cFileOpen := ""
Local cArquivo  := "VDFDEPA.INI"
Local _cArqquivo:= GetSrvProfString("StartPath","")+cArquivo
Local oModel 	:= FWModelActive()
Local oDlg, oMainWnd, oFilial, oFont
Local lRet		:= .F.

Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1") 
Local lLiberado	:= .T.

Private cCurric := FwFldGet( 'SQG->QG_CURRIC' )
Private cMat	  := Space(06)
Private aDePara := {}
Private aDeParaR:= {}

SQG->(DBSETORDER(1))
If SQG->( DbSeek(XFILIAL("SQG") + cCurric) )
	if SQG->(Columnpos("QG_ACTRSP")) > 0 .and. SQG->QG_ACTRSP <> '1' //1- sem aceite e 2-com aceite
		if ((cBlqCV == "2" .AND. SQG->QG_ACEITE == "2") .OR. cBlqCV <> "2") //1=Sem aceite; 2=Aceite vigente gravado                                                                                          
			lLiberado := .T.
		Endif
	else
		lLiberado := .F.
	endif
else
	lLiberado := .F.
ENDIF

If !lLiberado
	if !isBlind()
		Help(" ",1,OEMTOANSI( STR0013 ))
	ENDIF
else
	If IsBlind()
		Private lGp010Auto := .T.
	Endif

	cFileOpen :=_cArqquivo
	If !File(cFileOpen)
			Help(" ",1,STR0007 +_cArqquivo+ STR0008)  		//MsgInfo(STR0007 +_cArqquivo+ STR0008, '') //"Arquivo", " não localizado"
		Return()
	Endif
		If !IsBlind()
			Begin Sequence
				DEFINE FONT oFont NAME "Arial" SIZE 0,-16
				DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0011)  FROM 9,0 TO 25,80 OF oMainWnd //"Inclusão na Folha de Pagamento"
				@50,25 SAY OemToAnsi(STR0012) + ":"  FONT oFont of oDlg PIXEL  //"Escolha a filial de admissão do Membro/Servidor"
				@70,108 MSGET oFilial  VAR cFilServ   PICTURE "@!" VALID (fFilServ(cFilServ)) F3 "SRJFIL" SIZE 60,8 FONT oFont OF oDlg PIXEL HASBUTTON
				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||lRet:=fFilServ(cFilServ),,oDlg:End()},{||lRet:= .F.,,oDlg:End()})
			End Sequence
		Else
			cFilServ := cNewFil
			lRet	 := .T.
		Endif

	If lRet
		FT_FUSE(cFileOpen)         //ABRIR
		FT_FGOTOP()                //PONTO NO TOPO

		While !FT_FEOF()
			IncProc()
			cBuffer  := FT_FREADLN()
			nTamanho := Len( cBuffer )

			For I:=1 TO nTamanho

				If (AT("|",Substr(cBuffer,i,1))> 0)
					nFinal := I
				Endif
			Next

			aAdd(aDePara, { &(AllTrim(Subs(cBuffer, 1,nFinal-1))), AllTrim(Subs(cBuffer,nFinal+1,40))} )

			FT_FSKIP()
		endDo
		FT_FUSE()

		cFilAnt := cFilServ //substitui pela filial de admissao

		If IsBlind()
			For I:=1 TO Len(aDadosAut)
				aAdd(aDePara, {aDadosAut[I][1], aDadosAut[I][2]} )
				Next
		Endif

		If Gpea010Mnt( "SRA", Nil, 3, Nil, Nil, Nil, Nil )== 1

			Begin Transaction

				dbSelectArea("RI6")
				dbSetOrder(3)
				If dbSeek(xFilial("RI6")+FwFldGet('REY_CPF'))
					While !RI6->(Eof()) .And. RI6->RI6_FILIAL=xFilial("RI6")  .And. RI6->RI6_CPF=FwFldGet('REY_CPF')
						If Empty(RI6_MAT)
							RecLock("RI6",.F.)
							RI6_FILMAT := SRA->RA_FILIAL
							RI6_MAT    := SRA->RA_MAT
							RI6->(MsUnLock())
						Endif
						RI6->(dbSkip())
					Enddo
				Endif

				dbSelectArea("SQG")
				dbSetOrder(3)
				If dbSeek(FwxFilial("SQG")+FwFldGet('REY_CPF'))
					RecLock("SQG",.F.)
					QG_FILMAT := SRA->RA_FILIAL
					QG_MAT    := SRA->RA_MAT
					QG_DEPTO  := SRA->RA_DEPTO
					QG_SITUAC := '002'
					SQG->(MsUnLock())
				Endif

				dbSelectArea("REY")
				dbSetOrder(4)
				If dbSeek(FwxFilial("REY")+FwFldGet('REY_CPF')+FwFldGet('REZ_CODCON')+FwFldGet('REZ_FILFUN')+FwFldGet('REZ_CODFUN'))
					RecLock("REY",.F.)
					REY_EXERCI := SRA->RA_ADMISSA
					REY_DEPTO  := SRA->RA_DEPTO
					REY_SITUAC := '5'
					REY->(MsUnLock())

					//oModel:SetValue( 'REYDETAIL','REY_SITUAC', '5' )
					M->REY_SITUAC := '5'
				Endif

			//Grava RDZ/RD0
		/*	EntUpdateRd0(	''		,;							//01 -> Codigo da Pessoa
							'SRA'	,;							//02 -> Entidade Relacionada
							xFilial("SRA")+GetMemVar("RA_MAT"),;	//03 -> Chave da Entidade
							1		,;							//04 -> Ordem
							SRA->( Recno() )		,;			//05 -> Recno da Entidade
							cEmpAnt,;							//06 -> Codigo da Empresa
							cFilAnt,;							//07 -> Codigo da Filial
							"1"		,;							//08 -> Conteudo para o RD0_TIPO "1"=Interno;"2"=Externo
							.F.		,;							//09 -> Se Atualiza as Entidades Relacionadas
							NIL		,;							//10 -> Array com as Entidades para o Before Update
							NIL) 								//11 -> Array com as Entidades para o Later Update
		*/

			End Transaction
		Endif
	EndIf
ENDIF

RestArea(aArea)
cFilAnt := cFilBkp //restura filial original
	//Atualiza GRID
	oModel:DeActivate()
	oModel:Activate()
Return NIL


//------------------------------------------------------------------------------
/*/{Protheus.doc} VDF040DEPA
Preenche as Variaveis de Mem¢ria com Informacoes do Func.
@sample 	VDF040DEPA()
@author	    Nivia Ferreira
@since		13/08/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VDF040DEPA()
Local aArea   	:= GetArea()
Local aAreaSRJ	:= SRJ->( GetArea() )
Local aAreaSQ3	:= SQ3->( GetArea() )
Local aAreaRB6	:= RB6->( GetArea() )
Local nX 			:= 0
Local cCatFunc  	:= ''

dbSelectArea("SRJ")
dbSetOrder(1)
If dbSeek(FwFldGet('REY_FILFUN')+FwFldGet('REY_CODFUN'))
	Iif( IsMemVar( "RA_CARGO"	), M->RA_CARGO	:= SRJ->RJ_CARGO ,)
	Iif( IsMemVar( "RA_DCARGO"	), M->RA_DCARGO	:= SRJ->RJ_DESC	 ,)
Endif

dbSelectArea("SQ3")
dbSetOrder(1)
If dbSeek(FwxFilial("SQ3")+SRJ->RJ_CARGO)
		cCatFunc := SQ3->Q3_CATEG

	Iif( IsMemVar( "RA_TABELA"	), M->RA_TABELA := SQ3->Q3_TABELA,)
	Iif( IsMemVar( "RA_TABFAIX"	), M->RA_TABFAIX:= SQ3->Q3_TABFAIX,)
	Iif( IsMemVar( "RA_TABNIVE"	), M->RA_TABNIVE:= SQ3->Q3_TABNIVE,)
	Iif( IsMemVar( "RA_TABNIVE"	), M->RA_TABNIVE:= SQ3->Q3_TABNIVE,)
	Iif( IsMemVar( "RA_CATFUNC"	), M->RA_CATFUNC:= cCatFunc,)
	If cCatFunc='1' //Membros
	   Iif( IsMemVar( "RA_ADMISSA"	), M->RA_ADMISSA:= FwFldGet('REY_POSSE'),)
	Endif
Endif

dbSelectArea("RB6")
dbSetOrder(1)
If dbSeek(FwxFilial("RB6")+SQ3->Q3_TABELA+SQ3->Q3_TABNIVE+SQ3->Q3_TABFAIX)
	Iif( IsMemVar( "RA_SALARIO"	), M->RA_SALARIO:= RB6->RB6_VALOR,)
Endif

dbSelectArea('SRA')
For nX:=1 TO len(aDePara)
	&(aDePara[nX,2]) := aDePara[nX,1]
Next nX

RestArea( aAreaSRJ )
RestArea( aAreaSQ3 )
RestArea( aAreaRB6 )
	//RestArea(aArea)
Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} fFilServ
Valida o preenchimento da filial para cadastro do candidato à SRA.
@sample 	fFilServ()
@author	    esther.viveiro
@since		08/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------
Function fFilServ(cFilServ)
Local lRet := .T.
Local cFilFun := FwFldGet('REZ_FILFUN') //Filial da Função
Default cFilServ = ''

	If !(Len(AllTrim(cFilServ)) == Len(AllTrim(xFilial('SRA'))))
		Help(,,'Help',,STR0009,1,0) //"Filial informada não é válida para o cadastro de Membros/Servidores"
		lRet := .F.
	ElseIf !(xFilial("SRJ",cFilServ) == cFilFun) //se filial informada não fazer parte do nível de compartilhamento da Função
		Help(,,'Help',,STR0010,1,0) //"Filial informada não faz parte das filiais do grupo da Função escolhida para admissão. Escolha uma filial que faça parte do escopo da filial da função: "
		lRet := .F.
	EndIf

Return lRet
