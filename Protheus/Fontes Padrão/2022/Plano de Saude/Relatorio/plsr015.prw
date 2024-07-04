#INCLUDE "PROTHEUS.CH"

Static objCENFUNLGP := CENFUNLGP():New()
static lautoSt := .F.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSR015    ºAutor  ³Paulo Carnelossi   º Data ³  18/06/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime relacao de Internacoes com base nas guias de intern.º±±
±±º          ³hospitalar                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSR015(lauto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao de "
Local cDesc2 := "internacoes com base nas GIHs."
Local cDesc3 := ""
Local cString := "BE4"
Local Tamanho := "G"

default lAuto := .F.

PRIVATE cTitulo:= "Relacao de Diarias por Internacoes no Período de "
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR015"
Private nomeprog:= "PLSR015" 
Private nLastKey:=0

lAutoSt := lAuto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao dos cabecalhos                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cabec1:= "                                                                                                      Data       Data      Prestador Responsavel "
cabec2:= " Guia         Senha            Usuario                                                                Intern.    Alta                         "
//        123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456
//                 1         2         3         4         5         6         7         8         9        10        11        12
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "PLR015"

Pergunte(cPerg,.F.)

If !lAuto
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

	aAlias := {"BE4","BA0","BAU","BQV","BR8"}
	objCENFUNLGP:setAlias(aAlias)
endif

If !lAuto .AND. nLastKey == 27
   Return
End

If !lauto
	SetDefault(aReturn,cString)
endif

If !lAuto .AND. nLastKey == 27
   Return ( NIL )
End

If !lAuto
	RptStatus({|lEnd| PLSR015Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR015Imp(.F.,wnRel,cString)
endIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³PLSR015Imp³ Autor ³ Paulo Carnelossi      ³ Data ³ 18/06/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Impressao relacao de internacao com base nas GIHs           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³PLSR015Imp(lEnd,wnRel,cString)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSR015Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt
Local tamanho:= "G"
Local nTipo

LOCAL cSQL
Local cArqTrab := CriaTrab(nil,.F.)
Local cCodOpe, cCodRDA, lTitulo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

cTitulo += Dtoc(mv_par05)+" a "+Dtoc(mv_par06)

nTipo:=GetMv("MV_COMP")

cSQL := " SELECT BE4_CODOPE, BE4_CODRDA, BE4_DATPRO, BE4_DTALTA,BE4_ANOINT, BE4_MESINT, BE4_NUMINT, BE4_SENHA, BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_NOMUSR FROM "+RetSQLName("BE4")
cSQL += " WHERE BE4_FILIAL  >= '"+xFilial("BE4")
cSQL += "'  AND BE4_CODOPE >= '"+mv_par01      + "' AND BE4_CODOPE <= '"+mv_par02
cSQL += "'  AND BE4_CODRDA >= '"+mv_par03      + "' AND BE4_CODRDA <= '"+mv_par04
cSQL += "'  AND BE4_DATPRO >= '"+DTOS(mv_par05)+ "' AND BE4_DATPRO <= '"+DTOS(mv_par06)
cSQL += "' ORDER BY BE4_CODOPE, BE4_CODRDA, BE4_DATPRO"

PLSQuery(cSQL,cArqTrab)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Trata se nao existir registros...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
(cArqTrab)->(DbGoTop())

dbSelectArea(cArqTrab)
If !lAutoSt
	SetRegua(RecCount())
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta todas as localidades existentes...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While (cArqTrab)->( ! Eof())
	
	If !lAutoSt
		IncRegua()
	endif
   cCodOpe := (cArqTrab)->BE4_CODOPE
   
   While (cArqTrab)->( ! Eof() .And. BE4_CODOPE == cCodOpe )

      cCodRDA := (cArqTrab)->BE4_CODRDA
      lTitulo := .T.
      
		While (cArqTrab)->( ! Eof() .And. BE4_CODOPE == cCodOpe .And. ;
													BE4_CODRDA == cCodRDA )

			IF !lAutoSt .AND. li > 58
				cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
				lTitulo := .T.
			End
		   
		   If !lAutoSt .AND. lTitulo
				@li,001 PSAY "Operadora: "+	objCENFUNLGP:verCamNPR("BE4_CODOPE",cCodOpe) + " - " +;
											objCENFUNLGP:verCamNPR("BA0_NOMINT",Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),50))
				@li,070 PSAY "Cred/Coop.: "+objCENFUNLGP:verCamNPR("BE4_CODRDA",cCodRDA)+ " - " +;
											objCENFUNLGP:verCamNPR("BAU_NOME",Padr(Posicione("BAU",1,xFilial("BAU")+cCodRDA,"BAU_NOME"),50))
				li+=2
				lTitulo := .F.
	      EndIf
	      
	      If !lAutoSt .AND. ! Empty((cArqTrab)->BE4_DATPRO)
		      @li,001 PSAY 	objCENFUNLGP:verCamNPR("BE4_MESINT",(cArqTrab)->(BE4_MESINT))+;
			  				objCENFUNLGP:verCamNPR("BE4_NUMINT",(cArqTrab)->(BE4_NUMINT))
		      @li,013 PSAY 	objCENFUNLGP:verCamNPR("BE4_SENHA",(cArqTrab)->BE4_SENHA)
		      @li,031 PSAY 	objCENFUNLGP:verCamNPR("BE4_NOMUSR",Alltrim((cArqTrab)->BE4_NOMUSR))+" ("+;
			  				objCENFUNLGP:verCamNPR("BE4_OPEUSR",(cArqTrab)->(BE4_OPEUSR))+;
							objCENFUNLGP:verCamNPR("BE4_CODEMP",(cArqTrab)->(BE4_CODEMP))+;
							objCENFUNLGP:verCamNPR("BE4_MATRIC",(cArqTrab)->(BE4_MATRIC))+;
							objCENFUNLGP:verCamNPR("BE4_TIPREG",(cArqTrab)->(BE4_TIPREG))+;
							objCENFUNLGP:verCamNPR("BE4_DIGITO",(cArqTrab)->(BE4_DIGITO))+")"
		      @li,102 PSAY 	objCENFUNLGP:verCamNPR("BE4_DATPRO",(cArqTrab)->BE4_DATPRO)
		      @li,113 PSAY 	objCENFUNLGP:verCamNPR("BE4_DTALTA",(cArqTrab)->BE4_DTALTA)
		      @li,123 PSAY "PRESTADOR RESPONSAVEL        "//(cArqTrab)->BE4_MEDRES
		      li++
		      ImpEvolucao((cArqTrab)->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),cCodOpe, cCodRDA, lTitulo, @li, cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo, cArqTrab)
			EndIf
				
			(cArqTrab)->(dbSkip())
	
		End
		
		If ! lTitulo 
			li++
		EndIf
		
	End
	if lAutoSt .AND. !(cArqTrab)->(eOF())
		(cArqTrab)->(dbSkip())
	endif
End

IF !lAutoSt .AND. li != 80
	roda(cbcont,cbtxt,tamanho)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cArqTrab)
dbCloseArea()
dbSelectArea("BE4")

If !lAutoSt
	Set Device To Screen

	If aReturn[5] = 1
	Set Printer To
		dbCommitAll()
	OurSpool(wnrel)
	Endif

	MS_FLUSH()
endif
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ImpEvolucao ºAutor ³Paulo Carnelossi   º Data ³  18.06.03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime as evolucoes de diarias - Tabela BQV                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpEvolucao(cChave,cCodOpe, cCodRDA, lTitulo, li, cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo, cArqTrab)
Local aArea := GetArea()
Local aTipDia:= {}
Local lFirst := .T.
Local nTotal := 0
Local nDiarias := 0
Local lSubTot  := .F.
Local dDatSai := CTOD("")

QNCCBOX("BQV_TIPDIA",aTipDia)

dbSelectArea("BQV")
dbSeek(xFilial("BQV")+cChave)

While BQV->(! Eof() .And. BQV_FILIAL == xFilial("BQV") .And. BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT == cChave)
	
	IF li > 58
		IIF( !lAutoSt, cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo), '')
		lTitulo := .T.
	End 
	
	If lTitulo
		@li,001 PSAY "Operadora: "+	objCENFUNLGP:verCamNPR("BE4_CODOPE",cCodOpe) + " - " + objCENFUNLGP:verCamNPR("BA0_NOMINT",Padr(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"),50))
		@li,070 PSAY "Cred/Coop.: "+objCENFUNLGP:verCamNPR("BE4_CODRDA",cCodRDA)+ " - " + objCENFUNLGP:verCamNPR("BAU_NOME",Padr(Posicione("BAU",1,xFilial("BAU")+cCodOpe,"BAU_NOME"),50))
		li+=2
		lTitulo := .F.
	EndIf
	
	If lFirst
		@ li, 078 PSAY "Tp.Diaria   Procedimento                                                Dt.Entrada  Dt.Saida   Diagnostico                     No.Diarias"
		li++
		@ li, 078 PSAY "-----------------------------------------------------------------------------------------------------------------------------------------"
		li++
      lFirst := .F.
  	EndIf
	    
	
   @ li, 078 PSAY Padr(aTipDia[Val(BQV_TIPDIA)],10)
   @ li, 090 PSAY 	objCENFUNLGP:verCamNPR("BQV_CODPAD",BQV_CODPAD)+"/"+;
   					objCENFUNLGP:verCamNPR("BQV_CODPRO",Alltrim(BQV_CODPRO))+"-"+;
					objCENFUNLGP:verCamNPR("BR8_DESCRI",PADR(Posicione("BR8",1,xFilial("BR8")+BQV_CODPAD+BQV_CODPRO,"BR8_DESCRI"),40))
   If BQV->( FieldPos("BQV_DATPRO") ) > 0
	   @ li, 150 PSAY objCENFUNLGP:verCamNPR("BQV_DATPRO",BQV_DATPRO)
   EndIf	   
                                             
   If BQV->( FieldPos("BQV_DATPRO") ) > 0
		nDiarias := R015Diarias(cChave, BQV_DATPRO, cArqTrab, @dDatSai)
   EndIf	
   lSubTot  := .T.
   nTotal   += nDiarias
   
   @ li, 162 PSAY dDatSai
   @ li, 173 PSAY objCENFUNLGP:verCamNPR("BQV_DIAGNO",BQV_DIAGNO)
   @ li, 205 PSAY Str(nDiarias,10)

   li++
   
	dbSelectArea("BQV")
   dbSkip()
 
End

//imprime subtotal quando muda a chave
If lSubTot 
 	@ li, 190 PSAY "Total ----->"
  	@ li, 205 PSAY Str(nTotal,10)
  	li++
EndIf	

RestArea(aArea)

Return
//-----------------------------------------------------------------------------------

Static Function R015Diarias(cChave, dDatAnt, cAlias, dDatSai)
Local nDias := 0
Local nRegBQV := BQV->(Recno())

BQV->(dbSkip())

//verifica se proximo e da mesma GIH 
If BQV->(! Eof() .And. BQV_FILIAL == xFilial("BQV") .And. BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT == cChave)
   If BQV->( FieldPos("BQV_DATPRO") ) > 0
   	   nDias := BQV->(BQV_DATPRO) - dDatAnt
	   dDatSai := BQV->(BQV_DATPRO)
   EndIf		
ElseIf ! Empty((cAlias)->BE4_DTALTA)
	nDias := (cAlias)->BE4_DTALTA - dDatAnt
	dDatSai := (cAlias)->BE4_DTALTA
Else
	nDias := dDataBase - dDatAnt
	dDatSai := CTOD("")
EndIf

BQV->(dbGoto(nRegBQV))

Return(nDias)
