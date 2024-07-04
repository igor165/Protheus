#include "protheus.ch"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutost := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR740    ºAutor  ³Paulo Carnelossi   º Data ³  21/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de Movimentacao ocorrida com usuarios em    º±±
±±º          ³determinado periodo por operadora                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR740(lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao de "
Local cDesc2 := "movimentacao ocorrida com os usuarios em determinado periodo."
Local cDesc3 := ""
Local cString := "BA1"
Local Tamanho := "G"

Default lauto := .F.

PRIVATE cTitulo:= "Relatorio de Movimentacao dos Beneficiarios"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR740"
Private nomeprog:= "PLSR740" 
Private nLastKey:=0

lAutost := lauto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= "Matricula   Nome                                              Data Inclusao       Data Exclusao"
cabec2:= ""
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR740"

Pergunte(cPerg,.F.)
if !lauto
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)
endif
	aAlias := {"BA3","BA1","BG9","BI3"}
	objCENFUNLGP:setAlias(aAlias)

If !lauto .AND. nLastKey == 27
   Return
End

if !lauto
	SetDefault(aReturn,cString)
endif

If !lauto .AND. nLastKey == 27
   Return ( NIL )
End

if !lauto
	RptStatus({|lEnd| PLSR740Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR740Imp(.F.,wnRel,cString)
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR740Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 07/07/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de Movimentos dos Beneficiarios				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR740Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR740Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo

LOCAL cSQL, cSQL2
Local cArqTrab := CriaTrab(nil,.F.)
Local cArqTot  := CriaTrab(nil,.F.)
Local cCodOpe  := mv_par01
Local lTitulo, cCodEmp, cCodPro, cDatExc
Local nCtdMovPro, nCtdMovEmp
Local nTotComMov:=0, nTotSemMov:=0, nTotUsuMov:=0
Local cMatric

Local nAnterior := nTraSaida := nTraEntrada := nInclusao := nTitular := nDepend := 0
Local	nEmpTraSaida := nEmpTraEntrada := nEmpInclusao := nEmpExclusao := nEmpTitular := nEmpDepend := 0
Local	nTotAnterior := nTotTraSaida := nTotTraEntrada := nTotInclusao := nTotExclusao := nTotTitular := nTotDepend := 0

Local aStruct  := { {"BA1_CODEMP", "C", 4, 0}, {"TOTUSU", "N", 10, 0} }

//bloco de codigo para incrementar ou decrementar titular e dependente
Local bContaUsu := {|lSoma|If(lSoma,If((cArqTrab)->BA1_TIPREG = '00', nTitular++, nDepend++),If((cArqTrab)->BA1_TIPREG = '00', nTitular--, nDepend--))}
Local oTempTRB

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cTitulo :=	"Relacao Analitica de Movimentacao de Beneficiarios no Periodo de "
cTitulo += DTOC(mv_par04) +" a "+DTOC(mv_par05)
cTitulo +=  "   ***  Operadora : "+cCodOpe+" - "+ Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),45)

If mv_par06 == 2 // relatorio sintetico
	cabec1 := "Empresa                                                                 Anterior  Tr.Saida Tr.Entrada  Exclusao  Inclusao   Titular   Depend.   Efetivo"
EndIf
	
nTipo:=GetMv("MV_COMP")

//--< Criação do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "cArqInd" )
oTempTRB:SetFields( aStruct )
oTempTRB:AddIndex( "INDTRB",{ "BA1_CODEMP" } )
	
if( select( "cArqInd" ) > 0 )
	cArqInd->( dbCloseArea() )
endIf
	
oTempTRB:Create()

If mv_par04 > CTOD("")
	cSQL2 := "SELECT BA1.BA1_CODEMP, COUNT(BA1_CODEMP) AS TOTUSU FROM "
	cSQL2 += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
	//--relacionar usuario com familia
	cSQL2 += "WHERE "
	cSQL2 += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
	cSQL2 += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
	cSQL2 += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
	cSQL2 += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
	//--considerar somente registros validos
	cSQL2 += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
	//--condicao principal 
	cSQL2 += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
	cSQL2 += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
	cSQL2 += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
	//--faixa de produtos
	cSQL2 += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"
	
	cSQL2 += "	AND "
	cSQL2 += "	BA1.BA1_DATINC <'"+DTOS(MV_PAR04)+"' AND "
	cSQL2 += "	(BA1.BA1_DATBLO = '   ' OR BA1.BA1_DATBLO >='"+DTOS(MV_PAR04)+"') AND"
	cSQL2 += "	(BA1.BA1_DATTRA = '   ' OR BA1.BA1_DATTRA >='"+DTOS(MV_PAR04)+"')"
	
	cSQL2 += " GROUP BY BA1.BA1_CODEMP"
	cSQL2 += " ORDER BY BA1.BA1_CODEMP"
	
	PLSQuery(cSQL2,cArqTot)
	
	(cArqTot)->(dbGotop())
	dbSelectArea(cArqTot)

	While	(cArqTot)->(! EOF())
	
		cArqInd->(dbAppend())
		cArqInd->BA1_CODEMP	:= (cArqTot)->BA1_CODEMP
		cArqInd->TOTUSU		:= (cArqTot)->TOTUSU
		
		(cArqTot)->(dbSkip())
	
	End

EndIf
	
cSQL := "SELECT BA1.BA1_FILIAL,BA1.BA1_CODINT,BA1.BA1_CODEMP, BA1.BA1_CONEMP,"
cSQL += "BA1.BA1_VERCON, BA1.BA1_SUBCON, BA1.BA1_VERSUB, BA1.BA1_MATRIC,BA1.BA1_TIPREG,"
cSQL += "BA1.BA1_DIGITO, BA1.BA1_NOMUSR, BA1.BA1_DATINC, BA1.BA1_DATBLO, BA1.BA1_DATTRA,"
cSQL += "BA3.BA3_FILIAL,BA3.BA3_CODINT,BA3.BA3_CODEMP, BA3.BA3_CONEMP, BA3.BA3_VERCON, "
cSQL += "BA3.BA3_SUBCON, BA3.BA3_VERSUB, BA3.BA3_CODPLA FROM "
cSQL += RetSQLName("BA1")+" BA1, "+RetSQLName("BA3")+" BA3 "
//--relacionar usuario com familia
cSQL += "WHERE "
cSQL += "BA1.BA1_FILIAL = BA3.BA3_FILIAL AND "
cSQL += "BA1.BA1_CODINT  = BA3.BA3_CODINT AND "
cSQL += "BA1.BA1_CODEMP = BA3.BA3_CODEMP AND "
cSQL += "BA1.BA1_MATRIC = BA3.BA3_MATRIC AND "
//--considerar somente registros validos
cSQL += "BA1.D_E_L_E_T_ <> '*' AND BA3.D_E_L_E_T_ <> '*'  AND "
//--condicao principal 
cSQL += "	BA1.BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSQL += "	BA3.BA3_FILIAL = '"+xFilial("BA3")+"' AND "
cSQL += "	BA1.BA1_CODINT = '"+MV_PAR01+"' AND "
//--faixa de produtos
cSQL += "	BA3.BA3_CODPLA >='"+MV_PAR02+"' AND BA3.BA3_CODPLA <='"+MV_PAR03+"'"

If mv_par07 == 1
	//--movimentos no periodo
	cSQL += "	AND ("
	cSQL += "	(BA1.BA1_DATINC >='"+DTOS(MV_PAR04)+"' AND BA1.BA1_DATINC <='"+DTOS(MV_PAR05)+"')"
	cSQL += "	OR"
	cSQL += "	(BA1.BA1_DATBLO >='"+DTOS(MV_PAR04)+"' AND BA1.BA1_DATBLO <='"+DTOS(MV_PAR05)+"')"
	cSQL += "	OR"
	cSQL += "	(BA1.BA1_DATTRA >='"+DTOS(MV_PAR04)+"' AND BA1.BA1_DATTRA <='"+DTOS(MV_PAR05)+"')"
	cSQL += "	)"
EndIf

If mv_par06 == 1 // relatorio analitico
	cSQL += "ORDER BY BA1.BA1_CODEMP, BA3.BA3_CODPLA"
Else
	cSQL += "ORDER BY BA1.BA1_CODEMP, BA1.BA1_MATRIC"
EndIf

PLSQuery(cSQL,cArqTrab)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cArqTrab)->(DbGoTop())

dbSelectArea(cArqTrab)
if !lAutost
	SetRegua(RecCount())
endif

If mv_par06 == 1 // relatorio analitico
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Varre todos os usuarios                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cArqTrab)->( ! Eof())
		if !lAutost
			IncRegua()
		endif
		cCodEmp := (cArqTrab)->(BA1_CODEMP)
	   lTitulo := .T.
	   nAnterior := nEmpInclusao := nEmpExclusao := nCtdMovEmp := 0
	      
		While (cArqTrab)->( ! Eof() .And. BA1_CODINT == cCodOpe .And. ;
														BA1_CODEMP == cCodEmp)
	
	      cCodPro := (cArqTrab)->(BA3_CODPLA)
	      lTitulo := .T.
		   nInclusao := nExclusao := nCtdMovPro := 0
	      
			While (cArqTrab)->( ! Eof() .And. BA1_CODINT == cCodOpe .And. ;
															BA1_CODEMP == cCodEmp .And.;
	                                          BA3_CODPLA == cCodPro)
				IF li > 58
					cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
					lTitulo := .T.
				End
		
			   If lTitulo 
			      @ li, 000 PSAY objCENFUNLGP:verCamNPR("BA1_CODEMP",(cArqTrab)->BA1_CODEMP) +" - "+;
				  				 objCENFUNLGP:verCamNPR("BG9_DESCRI",Padr(Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI"),40))
			      @ li, 070 PSAY objCENFUNLGP:verCamNPR("BA3_CODPLA",(cArqTrab)->BA3_CODPLA) +" - "+;
				  				 objCENFUNLGP:verCamNPR("BI3_DESCRI",Padr(Posicione("BI3",1,xFilial("BI3")+cCodOpe+cCodPro,"BI3_DESCRI"),40))
					li+=2
					lTitulo := .F.
		      EndIf
		      
	         If mv_par07 == 1 .Or. ;
					(	(cArqTrab)->(DTOS(BA1_DATINC) >= DTOS(MV_PAR04) .AND.;
						DTOS(BA1_DATINC) <= DTOS(MV_PAR05)) .OR.	;
						(cArqTrab)->(DTOS(BA1_DATBLO) >= DTOS(MV_PAR04) .AND. ;
						DTOS(BA1_DATBLO) <= DTOS(MV_PAR05))	 .OR.	;
						(cArqTrab)->(DTOS(BA1_DATTRA) >= DTOS(MV_PAR04) .AND. ;
						DTOS(BA1_DATTRA) <= DTOS(MV_PAR05))	 )
					
			      @li,000 PSAY 	objCENFUNLGP:verCamNPR("BA1_MATRIC",(cArqTrab)->BA1_MATRIC)+"."+;
				  				objCENFUNLGP:verCamNPR("BA1_TIPREG",(cArqTrab)->BA1_TIPREG)+'-'+;
								objCENFUNLGP:verCamNPR("BA1_DIGITO",(cArqTrab)->BA1_DIGITO)
		   	   @li,012 PSAY Padr(objCENFUNLGP:verCamNPR("BA1_NOMUSR",(cArqTrab)->BA1_NOMUSR),48)
		      	@li,061 PSAY objCENFUNLGP:verCamNPR("BA1_DATINC",(cArqTrab)->BA1_DATINC)
	
		      	cDatExc := ""
		      	If (cArqTrab)->(Empty(BA1_DATBLO) .And. Empty(BA1_DATTRA) .OR. ;
		      	   BA1_DATBLO > mv_par05 .OR. BA1_DATTRA > mv_par05)
		      		@li,081 PSAY "*Inclusao*"
		      		nInclusao++
		      		nEmpInclusao++
		      	Else
		      		//tratar tb como inclusao quando a data inclusao estiver contida no periodo
		      	   If (cArqTrab)->(	DTOS(BA1_DATINC) >= DTOS(MV_PAR04) .AND.;
												DTOS(BA1_DATINC) <= DTOS(MV_PAR05))
							nInclusao++
							nEmpInclusao++
							nCtdMovPro++
		      			nCtdMovEmp++

						EndIf						
		      		nExclusao++
		      		nEmpExclusao++
		      		cDatExc := (cArqTrab)->(If(Empty(BA1_DATBLO),BA1_DATTRA, BA1_DATBLO))

		      		@li,081 PSAY IIF(Empty(BA1_DATBLO),objCENFUNLGP:verCamNPR("BA1_DATTRA",cDatExc),objCENFUNLGP:verCamNPR("BA1_DATBLO",cDatExc))
		      	EndIf	
	
		      	li++
	
		      	nCtdMovPro++
		      	nCtdMovEmp++
		      	nTotUsuMov++
		      	
		      EndIf
		   
		   	(cArqTrab)->(dbSkip())
		
			End
			
			If ! lTitulo .And. nCtdMovPro > 0
			   cVar := "Produto : "+objCENFUNLGP:verCamNPR("BA3_CODPLA",cCodPro)+;
			   		"    Movimentacao : "+Str(nCtdMovPro,10)+"   Inclusao : "+Str(nInclusao,10)+;
				   "    Exclusao : "+Str(nExclusao,10)+Space(28)
				@li,000 PSAY Padl(cVar ,220) 
				li++
			   @li,000 PSAY Padl(Replicate("-",len(cVar)),220)
				li++
			EndIf
			
		End
		
		If nCtdMovEmp == 0
			nTotSemMov++
		Else
			nTotComMov++
		EndIf
	   
	
		If mv_par04 > CTOD("") .And. cArqInd->(DbSeek(cCodEmp))
			nAnterior := cArqInd->TOTUSU
		EndIf
		@li,000 PSAY Padl("Total da Empresa : "+objCENFUNLGP:verCamNPR("BA1_CODEMP",cCodEmp)+;
			"    Movimentacao : "+Str(nCtdMovEmp,10)+"   Inclusao : "+Str(nEmpInclusao,10)+;
			"    Exclusao : "+Str(nEmpExclusao,10)+"    Saldo Atual : "+Str(nAnterior+nEmpInclusao-nEmpExclusao,10),220) 
		li++
	   @li,000 PSAY Replicate("-",220)
		li++
	
	   li++
	   
	   nTotInclusao += nEmpInclusao
	   nTotExclusao += nEmpExclusao
	   
	End
	
	@li,000 PSAY Padl("Total Geral Beneficiarios com Movimentacao : "+Str(nTotUsuMov,10),220) 
	li++
	@li,000 PSAY Padl("Total Geral Empresas com Movimentacao : "+Str(nTotComMov,10),220) 
	li++
	@li,000 PSAY Padl("Total Geral Empresas sem Movimentacao : "+Str(nTotSemMov,10),220) 
	li++
	@li,000 PSAY Padl("Total Geral Movimentacao : "+Str(nTotInclusao+nTotExclusao,10),220) 
	li++
	@li,000 PSAY Padl("Total Geral Inclusoes : "+Str(nTotInclusao,10),220) 
	li++
	@li,000 PSAY Padl("Total Geral Exclusoes : "+Str(nTotExclusao,10),220) 
	li++
	@li,000 PSAY Replicate("=",220)
	li++

Else  	//sintetico

	While (cArqTrab)->(! Eof())

		if !lAutost
			IncRegua()
		endif

		IF li > 58
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		End

		cCodEmp := (cArqTrab)->(BA1_CODEMP)
		nAnterior := 0
		nEmpTraSaida := nEmpTraEntrada := nEmpInclusao := nEmpExclusao := nEmpTitular := nEmpDepend := 0
	      
		While (cArqTrab)->( ! Eof() .And. BA1_CODINT == cCodOpe .And. ;
														BA1_CODEMP == cCodEmp)
	
			cMatric := (cArqTrab)->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
			nTraSaida := nTraEntrada := nInclusao := nExclusao := nTitular := nDepend := 0
			
			While (cArqTrab)->(! Eof() .And. BA1_CODINT+BA1_CODEMP+BA1_MATRIC == cMatric)
				//contagem de titulares e dependentes
				//somente contar quando a data de inclusao for
				//menor ou igual que o final do periodo (mv_par05) e 
				//a data de bloqueio ou transferencia seja vazia
				//OU quando a data de inclusao for
				//menor ou igual que o final do periodo (mv_par05) e 
				//a data de bloqueio seja maior que a data inicial do periodo
				//OU idem para transferencia
				If (cArqTrab)->(	(DTOS(BA1_DATINC) <= DTOS(MV_PAR05) .And. ;
										 Empty(BA1_DATBLO) .And. Empty(BA1_DATTRA))	 .OR.;
										(DTOS(BA1_DATINC) <= DTOS(MV_PAR05) .And. ; 
										 DTOS(BA1_DATBLO) >= DTOS(MV_PAR04) ) .OR. ;
										(DTOS(BA1_DATINC) <= DTOS(MV_PAR05) .And. ; 
										 DTOS(BA1_DATTRA) >= DTOS(MV_PAR04) ) ;				  
									 )
					Eval(bContaUsu, .T.)
				EndIf
					
				If (cArqTrab)->( DTOS(BA1_DATINC) >= DTOS(MV_PAR04) .And. ;
				    					DTOS(BA1_DATINC) <= DTOS(MV_PAR05) .And. ;
				    					BA1_DATINC <> BA1_DATTRA) 
                nInclusao++
			   EndIf

			   If (cArqTrab)->(Empty(BA1_DATBLO) .And. BA1_DATINC == BA1_DATTRA .And. ;
			       DTOS(BA1_DATINC) >= DTOS(MV_PAR04) .And. ;
				    DTOS(BA1_DATINC) <= DTOS(MV_PAR05) )
				
			       nTraEntrada++
	
			   ElseIf (cArqTrab)->(Empty(BA1_DATBLO) .And. BA1_DATINC <= BA1_DATTRA .And. ;
			       DTOS(BA1_DATINC) >= DTOS(MV_PAR04) .And. ;
				    DTOS(BA1_DATINC) <= DTOS(MV_PAR05) .And. ;
				    DTOS(BA1_DATTRA) >= DTOS(MV_PAR04) .And. ;
				    DTOS(BA1_DATTRA) <= DTOS(MV_PAR05)  )
				
			       nTraSaida++
			       Eval(bContaUsu, .F.)
				
	
			   ElseIf (cArqTrab)->(Empty(BA1_DATTRA) .And.  ! Empty(BA1_DATBLO) .And. ;
			       DTOS(BA1_DATBLO) >= DTOS(MV_PAR04) .And. ;
				    DTOS(BA1_DATBLO) <= DTOS(MV_PAR05) )
				
			       nExclusao++
			       Eval(bContaUsu, .F.)

			   EndIf
			   
				(cArqTrab)->(DbSkip())
				
			End
			
			nEmpTraSaida += nTraSaida
			nEmpTraEntrada += nTraEntrada
			nEmpInclusao += nInclusao
			nEmpExclusao += nExclusao
			nEmpTitular += nTitular
			nEmpDepend += nDepend
		
		End
			
		If mv_par04 > CTOD("") .And. cArqInd->(DbSeek(cCodEmp))
			nAnterior := cArqInd->TOTUSU
		EndIf
		
		//imprime linha do relatorio
      @li,000 PSAY 	objCENFUNLGP:verCamNPR("BA1_CODEMP",cCodEmp)+" - "+;
	  				objCENFUNLGP:verCamNPR("BG9_DESCRI",Padr(Posicione("BG9",1,xFilial("BG9")+cCodOpe+cCodEmp,"BG9_DESCRI"),40))

   	@li,070 PSAY Str(nAnterior,10)
      @li,080 PSAY Str(nEmpTraSaida,10)
      @li,091 PSAY Str(nEmpTraEntrada,10)
      @li,101 PSAY Str(nEmpExclusao,10)
      @li,111 PSAY Str(nEmpInclusao,10)
      @li,121 PSAY Str(nEmpTitular,10)
      @li,131 PSAY Str(nEmpDepend,10)
      //que deve ser igual ao numero de titular+dependente
      @li,141 PSAY Str((nAnterior+nEmpTraEntrada+nEmpInclusao-(nEmpTraSaida+nEmpExclusao)),10)
      li++
      
      nTotAnterior += nAnterior
      nTotTraSaida += nEmpTraSaida
      nTotTraEntrada += nEmpTraEntrada
      nTotExclusao += nEmpExclusao
      nTotInclusao += nEmpInclusao
      nTotTitular += nEmpTitular
      nTotDepend += nEmpDepend

   End

	//imprime linha do relatorio
	li++
   @li,000 PSAY "** Total Geral **'

	@li,070 PSAY Str(nTotAnterior,10)
	@li,080 PSAY Str(nTotTraSaida,10)
	@li,091 PSAY Str(nTotTraEntrada,10)
	@li,101 PSAY Str(nTotExclusao,10)
	@li,111 PSAY Str(nTotInclusao,10)
	@li,121 PSAY Str(nTotTitular,10)
	@li,131 PSAY Str(nTotDepend,10)
	//que deve ser igual ao numero de titular+dependente
	@li,141 PSAY Str((nTotAnterior+nTotTraEntrada+nTotInclusao-(nTotTraSaida+nTotExclusao)),10)
	li++
	   
   
EndIf

IF !lAutost .AND. li != 80
	roda(cbcont,cbtxt,tamanho)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTrab)
dbCloseArea()

dbSelectArea(cArqTot)
dbCloseArea()

if( select( "cArqInd" ) > 0 )
	oTempTRB:delete()
endIf

dbSelectArea("BA1")

if !lAutost
	Set Device To Screen
endif

If !lAutost .AND. aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

if !lAutost
	MS_FLUSH()
endif

Return
