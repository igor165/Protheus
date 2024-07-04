#INCLUDE "MATA983.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATA983   ³ Autor ³Andressa Ataides       ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Integracao com o Word para geracao de um relatorio por for- ³±±
±±³          ³necedor referente a Lei 10.485 de 2002 - Comprovante Mensal ³±±
±±³          ³de Retencao - Contribuicao para o PIS/PASEP e COFINS        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL = lRet = .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA983()    
Local	 	lRet		:=	.T.
Local	 	cPerg		:=	"MTA983"
Local	 	aIndexSA2	:=	{}
Local	 	cFiltraSA2	:=	'A2_FILIAL==xFilial ("SA2") .And. A2_COD>=MV_PAR06 .And. A2_LOJA>=MV_PAR08 .And. A2_COD<=MV_PAR07 .And. A2_LOJA<=MV_PAR09'
Local   	lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)
Private		bFiltraBrw	:=	{|| Nil}
Private		cCadastro 	:= OemToAnsi(STR0001)
Private		cPath		:=	""
Private		cArquivo	:=	""
Private		aRotina		:= MenuDef()
Private		cWord		:=	""

If !lVerpesssen .Or. !(Pergunte (cPerg, .T.))
    Return (lRet)
Endif

cArquivo 	:=	Alltrim (MV_PAR03)
cPath		:=	AllTrim (MV_PAR04)

If !(File (cPath+cArquivo))
	Help(" ",1, "A9810001",,STR0051, 1, 0)//"Arquivo de Modelo nao encontrado !!"
	Return (lRet)
Endif

//
cWord	:=	OLE_CreateLink ()
If (cWord < "0")
	Help(" ",1,"A9810004") //"MS-WORD nao encontrado nessa maquina !!"
	Return (lRet)
Endif
OLE_SetProperty(cWord, oleWdVisible  ,.F. )

DbSelectArea ("SA2")
SA2->(DbSetOrder (1))
bFiltraBrw := {|| FilBrowse ("SA2", @aIndexSA2, @cFiltraSA2)}
Eval (bFiltraBrw)
mBrowse (6, 1, 22, 75, "SA2")
EndFilBrw ("SA2", aIndexSA2)

OLE_CloseLink(cWord) //fecha o Link com o Word
Return (lRet)      
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³A983Impri ³ Autor ³Andressa Ataides       ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que trata sobre a integracao.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL = lRet = .T.                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A983Impri (cAlias, nReg, nOpcao)
#IFDEF TOP
	Local	aCamposSE2	:=	{}
	Local	aStruSE2	:=	{}
#ENDIF
Local	lRet		:=	.T.
Local	cQuery		:=	""
Local	cAliasSE2	:=	"SE2"
Local	nX			:=	0
Local	cIndex		:=	""
Local	nIndex		:=	0
Local	aTrbs		:=	{}
Local	nY			:=	0
Local	lGerou		:=	.F.
Local	nVar4Word	:=	30
Local	nCtd4Word	:=	1
Local	cChaveWhile	:=	""
Local	cUniao		:=	PadR( SuperGetMv( "MV_UNIAO" ),TamSx3("E2_FORNECE")[1] )
Local	cLojUniao	:=	PadR( "00",TamSx3("E2_LOJA")[1] )
Local	cNomeArq	:=	"RetMes"
Local	nNomeArq	:=	1   
Local	cCodFornece	:=	Iif (nOpcao==3, SA2->A2_COD, "")
Local	cLojFornece	:=	Iif (nOpcao==3, SA2->A2_LOJA, "")
Local	dData		:=	CToD("  /  /  ")
Local	nVlrPagto	:=	0
Local	cChaveSe5	:=	""
Local	cCodRPis	:=	""
Local	cCodRCof	:=	""
Local	nAbatBase	:=	0
Local	lMVMT983PG	:=	GetNewPar("MV_MT983PG",.F.)
Local 	lPCCBaixa 	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"
Local	nVRetPis	:=	0
Local	nVRetCof	:=	0
Local	cChave		:=	""

If ((Select ("__SE2"))<>0)
	__SE2->(DbCloseArea ())
EndIf
ChkFile ("SE2", .F., "__SE2")
__SE2->(DbGoTop ())

aTrbs	:=	CriaTrb ()

DbSelectArea (cAliasSe2)
(cAliasSe2)->(DbSetOrder(1))
#IFDEF TOP
    If TcSrvType()<>"AS/400"
		cAliasSe2	:=	"TOP"
    	aAdd (aCamposSE2, "E2_FILIAL")
    	aAdd (aCamposSE2, "E2_PREFIXO")
    	aAdd (aCamposSE2, "E2_NUM")
    	aAdd (aCamposSE2, "E2_PARCELA")
    	aAdd (aCamposSE2, "E2_EMISSAO")
    	aAdd (aCamposSE2, "E2_TIPO")
    	aAdd (aCamposSE2, "E2_NATUREZ")
    	aAdd (aCamposSE2, "E2_FORNECE")
    	aAdd (aCamposSE2, "E2_LOJA")
    	aAdd (aCamposSE2, "E2_VALOR")
    	aAdd (aCamposSE2, "E2_VENCREA")
    	aAdd (aCamposSE2, "E2_CODRET")
    	aAdd (aCamposSE2, "E2_IRRF")
    	aAdd (aCamposSE2, "E2_INSS")
    	aAdd (aCamposSE2, "E2_ISS")
    	aAdd (aCamposSE2, "E2_PIS")
    	aAdd (aCamposSE2, "E2_COFINS")
    	aAdd (aCamposSE2, "E2_CSLL")
    	aAdd (aCamposSE2, "E2_SALDO")
    	aAdd (aCamposSE2, "E2_FATURA")
    	aAdd (aCamposSE2, "E2_PARCPIS")
    	aAdd (aCamposSE2, "E2_PARCCOF")
		aAdd (aCamposSE2, "E2_SEST")
		aAdd (aCamposSE2, "E2_CODRPIS")
		aAdd (aCamposSE2, "E2_CODRCOF")
		
    	cQuery	:=	"SELECT "

    	aStruSe2	:=	M983E2Stru (aCamposSE2, @cQuery)
    	
    	cQuery	+=	"FROM "+RetSqlName( "SE2" )+" "	    	
    	cQuery	+=	"WHERE E2_FILIAL='"+xFilial( "SE2" )+"' AND "
		If MV_PAR12==1
			cQuery  +=  "E2_EMISSAO>='"+DToS( MV_PAR01 )+"' AND "
			cQuery  +=  "E2_EMISSAO<='"+DToS( MV_PAR02 )+"' AND "
		Else
			cQuery  +=  "E2_VENCREA>='"+DToS( MV_PAR01 )+"' AND "
			cQuery  +=  "E2_VENCREA<='"+DToS( MV_PAR02 )+"' AND "
		EndIf
		cQuery  +=  "(E2_FORNECE<>'"+cUniao+"' AND E2_LOJA<>'"+cLojUniao+"') AND "
		cQuery  +=  "(E2_PIS>0 OR E2_COFINS>0) AND "
		cQuery  +=  "(E2_FATURA='' OR E2_FATURA='NOTFAT') AND "
    	cQuery	+=	"D_E_L_E_T_=' ' "
		cQuery	+=	"ORDER BY "+SqlOrder (SE2->(IndexKey ()))
    	//
		cQuery := ChangeQuery (cQuery)
		DbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery), cAliasSe2)
		//
		For nX := 1 To Len (aStruSe2)
			If (aStruSe2[nX][2]<>"C")
				TcSetField (cAliasSe2, aStruSe2[nX][1], aStruSe2[nX][2], aStruSe2[nX][3], aStruSe2[nX][4])
			EndIf
		Next (nX)
    Else
#ENDIF
	cIndex	:= 	CriaTrab( Nil, .F. )
	cQuery	:=	'E2_FILIAL=="'+xFilial( "SE2" )+'" .And. '
	If MV_PAR12==1
		cQuery	+=	'DtoS( E2_EMISSAO )>="'+DtoS( MV_PAR01 )+'" .And. DtoS( E2_EMISSAO )<="'+DtoS( MV_PAR02 )+'" .And. '
	Else
		cQuery  +=  'DtoS( E2_VENCREA )>="'+DToS( MV_PAR01 )+'" .And. DtoS( E2_VENCREA )<="'+DToS( MV_PAR02 )+'" .And. '
	EndIf
	cQuery	+=  '!( E2_FORNECE=="'+cUniao+'" .And. E2_LOJA=="'+cLojUniao+'" ) .And. ( E2_PIS>0 .Or. E2_COFINS>0 ) .And. '
	cQuery	+=  '(Empty(E2_FATURA) .Or. "NOTFAT"$E2_FATURA)'

    IndRegua (cAliasSe2, cIndex, (cAliasSe2)->(IndexKey()),, cQuery)
    nIndex := RetIndex(cAliasSe2)

	#IFNDEF TOP
		DbSetIndex (cIndex+OrdBagExt ())
	#ENDIF
	//
	DbSelectArea (cAliasSe2)
    DbSetOrder (nIndex+1)
        (cAliasSe2)->(DbGoTop())
#IFDEF TOP
	EndIf
#ENDIF

While !((cAliasSe2)->(Eof()))
    //Filtro das perguntas
	If ( !Empty( cCodFornece+cLojFornece ) .And. cCodFornece+cLojFornece!=(cAliasSe2)->E2_FORNECE+(cAliasSe2)->E2_LOJA ) .Or.;
		( Empty ( cCodFornece+cLojFornece ) .And. (cAliasSe2)->E2_FORNECE+(cAliasSe2)->E2_LOJA<MV_PAR06+MV_PAR08 .Or. (cAliasSe2)->E2_FORNECE+(cAliasSe2)->E2_LOJA>MV_PAR07+MV_PAR09 )
		(cAliasSe2)->(DbSkip())
		Loop	
	EndIf
	
	cCodRPis	:=	""
	cCodRCof	:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifico se devo pegar o codigo de receita do titulo princial ou do TX(ELSE)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (((cAliasSe2)->E2_PIS>0 .And. !Empty( (cAliasSe2)->E2_CODRPIS )) .Or. ;
		((cAliasSe2)->E2_COFINS>0 .And. !Empty( (cAliasSe2)->E2_CODRCOF )))
		
		cCodRPis	:=	(cAliasSe2)->E2_CODRPIS
		cCodRCof	:=	(cAliasSe2)->E2_CODRCOF
	Else
		If (cAliasSe2)->E2_PIS>0
			If (__SE2->(dbSeek( xFilial( "SE2" )+(cAliasSe2)->E2_PREFIXO+(cAliasSe2)->E2_NUM+(cAliasSe2)->E2_PARCPIS+MVTAXA+cUniao+cLojUniao )))
				cCodRPis	:=	__SE2->E2_CODRET
			EndIf
		EndIf
		
		If (cAliasSe2)->E2_COFINS>0
			If (__SE2->(dbSeek( xFilial( "SE2" )+(cAliasSe2)->E2_PREFIXO+(cAliasSe2)->E2_NUM+(cAliasSe2)->E2_PARCCOF+MVTAXA+cUniao+cLojUniao )))
				cCodRCof	:=	__SE2->E2_CODRET
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sem codigo de receita nao eh possivel gerar o comprovante³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( Empty( cCodRPis ) .Or. Empty( cCodRCof ) )
		(cAliasSe2)->(DbSkip())
		Loop	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somatoria dos abatimentos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAbatBase	:= (cAliasSe2)->(E2_IRRF+E2_INSS+E2_ISS+E2_PIS+E2_COFINS+E2_CSLL)
	nAbatBase += SE2->E2_SEST

	dData		:=	Iif( MV_PAR12==1,(cAliasSe2)->E2_EMISSAO,(cAliasSe2)->E2_VENCREA )
	cChaveSe5	:=	xFilial( "SE5" )+(cAliasSe2)->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) 	
	nVlrPagto	:=	0
	cChave		:=	""
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Quando for retencao pela emissao, o valor retido eh o mesmo ³
	//³     gravado no E2_PIS e E2_COFINS, basta proporcionalizar  ³
	//³    conforme o pagamento.                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVRetPis	:=	Iif( lPCCBaixa,0,(cAliasSe2)->E2_PIS )
	nVRetCof	:=	Iif( lPCCBaixa,0,(cAliasSe2)->E2_COFINS )

	SE5->(dbSetOrder(7))

	If SE5->( dbSeek( cChaveSe5 ) )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³While para verificar se o registro de baixa estah cancelado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !SE5->(Eof()) .And.;
			SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)==cChaveSe5
			If SE5->E5_SITUACA<>"C" .And. !TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))				
				If ExistBlock("MTA983VP")
    				nVlrPagto := ExecBlock("MTA983VP",.F.,.F.,{nVlrPagto})  
	        	Else
	        		nVlrPagto	+=	SE5->E5_VALOR
	        	EndIf			
					If lPCCBaixa
						nVRetPis	+=	SE5->E5_VRETPIS
						nVRetCof	+=	SE5->E5_VRETCOF
					EndIf
			EndIf
			SE5->(dbSkip())
		EndDo
		
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verificacao do parametro que identifica se para este comprovante somente os titulos das notas fiscais ³
	//³   originais baixados devem ser considerados.                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nVlrPagto==0 .And. !lMVMT983PG	//.T., considera tudo, .F., somente os baixados
		(cAliasSe2)->(DbSkip())
		Loop		
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao tenha pago tambem nao devo reter nada.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lPCCBaixa
		If (nVlrPagto==0)
			nVRetPis	:=	0
			nVRetCof	:=	0
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Proporcionalizacao dos tributos em cima do pagamento da nota fiscal original³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVRetPis	:=	nVRetPis/((cAliasSe2)->E2_VALOR/nVlrPagto)
			nVRetCof	:=	nVRetCof/((cAliasSe2)->E2_VALOR/nVlrPagto)
		EndIf
	EndIf
	lGerou		:=	.T.
	
	For nX := 1 To 2
		If !Empty( Iif( nX==1,cCodRPis,cCodRCof ) )
			If TRB->( DbSeek( (cAliasSe2)->E2_FORNECE+(cAliasSe2)->E2_LOJA+StrZero( Month( dData ),2 )+;
				Iif( nX==1,cCodRPis,cCodRCof )))
				TRB->(RecLock( "TRB",.F. ))
			Else
				TRB->(RecLock( "TRB",.T. ))
				TRB->TRB_FORN	:=	(cAliasSe2)->E2_FORNECE
				TRB->TRB_LOJA	:=	(cAliasSe2)->E2_LOJA
				TRB->TRB_MES	:=	StrZero( Month( dData ),2 )
				TRB->TRB_ANO	:=	StrZero( Year( dData ),4 )
				TRB->TRB_CODRET	:=	Iif( nX==1,cCodRPis,cCodRCof )
			EndIf

			TRB->TRB_VLRPGO		+=	Iif(nX==1,nVlrPagto,0)
			//Se o pagamento foi feito menor, considero o valor pago, caso contrario, monto o valor total pago mais os abatimentos
			If nVlrPagto!=0 .And. (cAliasSe2)->E2_SALDO==0
				TRB->TRB_VLRPGO		+= Iif(nX==1,nAbatBase,0)	
			EndIf

			TRB->TRB_VLRRET		+=	Iif( nX==1,nVRetPis,nVRetCof )
			TRB->(MsUnLock())
		EndIf
	Next nX
	
	(cAliasSe2)->(DbSkip())
EndDo                           

If !lGerou
	If (nOpcao==3)
		xMagHelpFis( STR0035,STR0033,STR0059 )	//"Atencao"###"Sem movimento de retencao para este fornecedor !"###"Verificar o movimento do período e se todos possuem código de retenção relacionado."
	Else
		xMagHelpFis( STR0035,STR0036,STR0059 )	//"Atencao"###"Sem movimentacao para gerar este comprovante !"###"Verificar o movimento do período e se todos possuem código de retenção relacionado."
	EndIf
EndIf

#IFDEF TOP
	DbSelectArea (cAliasSe2)
	(cAliasSe2)->(DbCloseArea ())
#ELSE
  	DbSelectArea (cAliasSe2)
	RetIndex (cAliasSe2)
	(cAliasSe2)->(DbClearFilter ())
	Ferase (cIndex+OrdBagExt())
#ENDIF

If (lGerou)
	If (cWord >= "0")		
		OLE_CloseLink(cWord) //fecha o Link com o Word
		cWord	:=	OLE_CreateLink ()
		If (cWord < "0")
			Help(" ",1,"A9810004",,STR0050, 1, 0)//"MS-WORD nao encontrado nessa maquina !!"
			Return (lRet)
		Endif
	
		OLE_NewFile (cWord, cPath+cArquivo)
		If nOpcao==3
			OLE_SetProperty (cWord, oleWdVisible, .T.)
			OLE_SetProperty (cWord, oleWdPrintBack, .T.)
		Else
			OLE_SetProperty (cWord, oleWdVisible, .F.)
			OLE_SetProperty (cWord, oleWdPrintBack, .F.)
		EndIf
	
		DbSelectArea ("TRB")
		TRB->(DbGoTop ())
		Do While !(TRB->(Eof()))
	  
			cChaveWhile	:=	TRB->TRB_FORN+TRB->TRB_LOJA
	
			DbSelectArea ("SA2")
			SA2->(MsSeek (xFilial("SA2")+TRB->TRB_FORN+TRB->TRB_LOJA))
			//
			OLE_SetDocumentVar (cWord, "c_Calendario" ,SUBSTR(DTOS(MV_PAR01),5,2)+"/"+SUBSTR(DTOS(MV_PAR01),1,4)) 
			OLE_SetDocumentVar (cWord, "c_Nome1" , SM0->M0_NOMECOM)
			OLE_SetDocumentVar (cWord, "c_Cnpj1" , Transform (SM0->M0_CGC, "@R 99.999.999/9999-99"))
			OLE_SetDocumentVar (cWord, "c_Nome2" , SA2->A2_NOME)
			OLE_SetDocumentVar (cWord, "c_Cnpj2" , Transform (SA2->A2_CGC, "@R 99.999.999/9999-99"))
			//
			Do While !(TRB->(Eof ())) .And. (cChaveWhile==TRB->TRB_FORN+TRB->TRB_LOJA)
				OLE_SetDocumentVar (cWord, "c_Mes"+AllTrim(Str(nCtd4Word)),MesExtenso(Val(TRB->TRB_MES)))
				OLE_SetDocumentVar (cWord, "c_Codigo"+AllTrim(Str(nCtd4Word)),TRB->TRB_CODRET)
				OLE_SetDocumentVar (cWord, "c_ValorPg"+AllTrim(Str(nCtd4Word)),Transform(TRB->TRB_VLRPGO, "@E 999,999,999,999.99"))
				OLE_SetDocumentVar (cWord, "c_ValorRet"+AllTrim(Str(nCtd4Word)),Transform(TRB->TRB_VLRRET, "@E 999,999,999,999.99"))
	
				nCtd4Word++
				TRB->(DbSkip ())
			EndDo
			//
			For nY := nCtd4Word To nVar4Word
				OLE_SetDocumentVar (cWord, "c_Mes"+AllTrim(Str(nY)), " ")
				OLE_SetDocumentVar (cWord, "c_Codigo"+AllTrim(Str(nY)), " ")
				OLE_SetDocumentVar (cWord, "c_ValorPg"+AllTrim(Str(nY)), " ")
				OLE_SetDocumentVar (cWord, "c_ValorRet"+AllTrim(Str(nY)), " ")
			Next (nX)
			nCtd4Word	:=	1
	
			OLE_SetDocumentVar (cWord, "c_Nome5", AllTrim (MV_PAR05))
	
			OLE_UpdateFields (cWord)
	
			If (nOpcao==4)
				If (MV_PAR10==1)
					OLE_PrintFile(cWord,"ALL",,,)
				Else
					OLE_SaveAsFile (cWord, AllTrim (MV_PAR11)+cNomeArq+StrZero (nNomeArq++, 3)+".DOC" )
				EndIF
			EndIf
		EndDo
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Removo todos os temporarios criados pela funcao CriaTrb.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len (aTrbs)
	DbSelectArea (aTrbs[nX][1])
		TRB->(DbCloseArea ())
	Ferase (aTrbs[nX][2]+GetDBExtension ())
	Ferase (aTrbs[nX][2]+OrdBagExt ())
Next (nX)

If ((Select ("__SE2"))<>0)
	__SE2->(DbCloseArea ())
EndIf
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CriaTrb   ³ Autor ³Andressa Ataides       ³ Data ³15.02.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que trata sobre a criacao do arquivos de trabalho.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpA = aRet = Array contendo {Alias, NomeTrb}               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaTrb ()

Local	aRet		:=	{}
Local	aTrb		:=	{}
Local	cAliasTrb	:=	""

aTrb	:=	{}

aAdd (aTrb, {"TRB_FORN",	"C",	TamSX3("A2_COD")[1],	TamSX3("A2_COD")[2]})
aAdd (aTrb, {"TRB_LOJA",	"C",	TamSX3("A2_LOJA")[1],	TamSX3("A2_LOJA")[2]})
aAdd (aTrb, {"TRB_MES",		"C",	02,	0})
aAdd (aTrb, {"TRB_ANO",		"C",	04,	0})
aAdd (aTrb, {"TRB_CODRET",	"C",	04,	0})
aAdd (aTrb, {"TRB_VLRPGO",	"N",	16,	2})
aAdd (aTrb, {"TRB_VLRRET",	"N",	16,	2})

cAliasTrb	:=	CriaTrab (aTrb)
DbUseArea (.T., __LocalDriver, cAliasTrb, "TRB")
IndRegua ("TRB", cAliasTrb,"TRB_FORN+TRB_LOJA+TRB_MES+TRB_CODRET")

aAdd (aRet, {"TRB", cAliasTrb})

Return (aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()
     
Private  aRotina	:= {	{STR0002,"PesqBrw"   , 0 , 1,0,.F.},;	//"Pesquisar"
							{STR0003,"AxVisual"  , 0 , 2,0,NIL},;	//"Visualizar"
							{STR0004,"A983Impri" , 0 , 3,0,NIL},;	//"Manual"
							{STR0005,"A983Impri" , 0 , 4,0,NIL}}  //"Automatica"


If ExistBlock("MT983MNU")
	ExecBlock("MT983MNU",.F.,.F.)
EndIf

Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M978E2StruºAutor³                     Gustavo G. Rueda                       ºData³  27/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao utilizada para montar a estrutura somente dos campos que compoe a query para ser utiliza-º±±
±±º          ³ do no TCSETFIELD.                                                                              º±±
±±º          ³                                                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºObservacao³Objetivando performance                                                                         º±±
±±º          ³                                                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos -> Campos a serem tratados                                                              º±±
±±º          ³cCmpQry -> String para dos campos para a query                                                  º±±
±±º          ³                                                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³nTrimFg -> Trimestre                                                                            º±±
±±º          ³                                                                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³M978E2Stru (aCampos, @cCmpQry)                                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#IFDEF TOP
Static Function M983E2Stru (aCampos, cCmpQry)
	Local	aRet	:=	{}
	Local	nX		:=	0
	Local	aTamSx3	:=	{}
	//
	For nX := 1 To Len (aCampos)
		If (FieldPos (aCampos[nX])>0)
			aTamSx3 := TamSX3 (aCampos[nX])
			aAdd (aRet, {aCampos[nX], aTamSx3[3], aTamSx3[1], aTamSx3[2]})
			//
			cCmpQry	+=	aCampos[nX]+", "
		EndIf
	Next (nX)
	//
	If (Len (cCmpQry)>0)
		cCmpQry	:=	" "+SubStr (cCmpQry, 1, Len (cCmpQry)-2)+" "
	EndIf
Return (aRet)
#ENDIF
