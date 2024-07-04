// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE 'Fwcommand.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VA610MUL ³ Autor ³  Thiago               ³ Data ³ 27/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Termo de responsabilidade de multas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VA610MUL

Local oPrint
Local i 	:= 1
Local lin 	:= 0
Private aImpCpo := {}
Private oFont16, oFont08, oFont10,oFont07, oFont12 , oFont06,oFont12w

oFont16	:= TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)
oFont06	:= TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Courier New",09,09,,.F.,,,,.T.,.F.)
oFont09	:= TFont():New("Courier New",09,09,,.T.,,,,.T.,.F.)
oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)

dbSelectArea("SX3")
dbSetOrder(1)
Dbseek("VAZ")
While !Eof() .And. (SX3->X3_ARQUIVO == "VAZ")
	IF X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
		AADD(aImpCpo,{ Alltrim(SX3->X3_CAMPO) , Alltrim(SX3->X3_TITULO) })
	EndIf
	dbSelectArea("SX3")		
	dbSkip()
EndDo

//If !VAZ->(Dbseek(xFilial("VAZ")+M->VAZ_CHASSI))
//	MsgStop("Avaliação ainda nao foi gravado") //"Avaliação ainda nao foi gravado"
//	Return
//Endif	
oPrint	:= TMSPrinter():New( "Termo de Responsabilidade" ) 
oPrint:setportraint()

oPrint:Setup()

MontaRel(oPrint,@i,@lin)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MONTAREL  ºAutor  ³Ricardo Farinelli   º Data ³  11/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao principal para confeccao do relatorio                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaRel(oPrint,i,lin)

Cabecalho(oPrint,@i)  			// Funcao que monta o cabecalho
//lin := Detail(oPrint,@i)  		// Funcao que monta o cabecalho
//If lin > 2700				// Espaco minimo para colocacao do rodape	
//	i++
//	oPrint:EndPage() 		// Finaliza a pagina
//	Cabecalho(oPrint,@i)
//	lin := 330
//Endif
//Resumo(oPrint,@i,@lin) // imprime o resumo da avaliacao
//
oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Cabecalho³ Autor ³ Ricardo Farinelli     ³ Data ³ 31/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Cabecalho(ExpO1,ExpN1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Capabili                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Cabecalho(oPrint,i)
Local cFig := GetSrvProfString("StartPath","")
Local aSM0FilAtu
If File(cFig+"LGRL"+cEmpAnt+cFilAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+cFilAnt+".BMP"
Elseif File(cFig+"LGRL"+cEmpAnt+".BMP")
	cFig +="LGRL"+cEmpAnt+".BMP"
Else
	cFig +="LGRL.BMP"
Endif
oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:SayBitmap(20,30,cFig ,250,80)

oPrint:Say(075,500,"TERMO DE RESPONSABILIDADE - PESSOA FÍSICA",oFont16 )

if Type("ParamIXB") <> "U"
	cRotina := ParamIxb[1]
Else
	cRotina := "1"
Endif	

aSM0FilAtu := FWArrFilAtu() // carrega todas as variaveis da Filial
cConcAtu  := aSM0FilAtu[SM0_NOME]
//cCNPJ     := asm0filatu[sm0_cgc]
cCNPJ     := asm0filatu[18]

if cRotina == "1"      
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+VAZ->VAZ_CODCLI+VAZ->VAZ_LOJCLI)
	cCliente := SA1->A1_NOME
	cRG      := SA1->A1_PFISICA
	cCPF     := (SA1->A1_CGC)
	cEnd     := substr(SA1->A1_END,1,40)		
	cCep     := (SA1->A1_CEP)
	cBairro  := (SA1->A1_BAIRRO)
	cMun     := (SA1->A1_MUN)
	cEst     := (SA1->A1_EST)
	cTel     := Alltrim(SA1->A1_TEL)
	cDDD     := (SA1->A1_DDD)
	dData    := dDataBase
	
	dbSelectArea("VE1")
	dbSetOrder(1)
	dbSeek(xFilial("VE1")+VAZ->VAZ_CODMAR)
	cMarca := (VE1->VE1_DESMAR)
	dbSelectArea("VV2")
	dbSetOrder(1)
	dbSeek(xFilial("VV2")+VAZ->VAZ_CODMAR+VAZ->VAZ_MODVEI)
	cDesMod := substr(VV2->VV2_DESMOD,1,25)
	cFabMod := VAZ->VAZ_FABMOD
	dbSelectArea("VVC")
	dbSetOrder(1)
	dbSeek(xFilial("VVC")+VAZ->VAZ_CODMAR+VAZ->VAZ_CORVEI)
	cCor    := VVC->VVC_DESCRI
	cPlaca  := VAZ->VAZ_PLAVEI
	dbSelectArea("VV1")
	dbSetOrder(2)
	dbSeek(xFilial("VV1")+VAZ->VAZ_CHASSI)
	cRenavam:= VV1->VV1_RENAVA
	cNumMot := VV1->VV1_NUMMOT
	cChassi := VV1->VV1_CHASSI
	cKilome := VAZ->VAZ_KILVEI
	cPessoa := SA1->A1_PESSOA
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+VVF->VVF_CODFOR+VVF->VVF_LOJA)
	cCliente := SA2->A2_NOME
	cRG     := SA2->A2_PFISICA
	cCPF    := (SA2->A2_CGC)
	cEnd    := substr(SA2->A2_END,1,40)		
	cCep    := (SA2->A2_CEP)
	cBairro := (SA2->A2_BAIRRO)
	cMun    := (SA2->A2_MUN)
	cEst    := (SA2->A2_EST)
	cTel    := Alltrim(SA2->A2_TEL)
	cDDD    := (SA2->A2_DDD)
	dData   := dDataBase
	cPessoa := SA2->A2_TIPO
	
	dbSelectArea("VVG")
	dbSetOrder(1)
	dbSeek(xFilial("VVG")+VVF->VVF_TRACPA)
	dbSelectArea("VV1")
	dbSetOrder(2)
	dbSeek(xFilial("VV1")+VVG->VVG_CHASSI)
	dbSelectArea("VE1")
	dbSetOrder(1)
	dbSeek(xFilial("VE1")+VV1->VV1_CODMAR)
	cMarca := (VE1->VE1_DESMAR)
	dbSelectArea("VV2")
	dbSetOrder(1)
	dbSeek(xFilial("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI)
	cDesMod := substr(VV2->VV2_DESMOD,1,25)
	cFabMod := VV1->VV1_FABMOD
	dbSelectArea("VVC")
	dbSetOrder(1)
	dbSeek(xFilial("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI)
	cCor    := VVC->VVC_DESCRI
	cPlaca  := VV1->VV1_PLAVEI
	cRenavam:= VV1->VV1_RENAVA
	cNumMot := VV1->VV1_NUMMOT
	cChassi := VV1->VV1_CHASSI
	cKilome := VV1->VV1_KILVEI
Endif

if cVersao == "P10"
	if cRotina == "1"      
		if cPessoa == "F"
			oPrint:Say(370,0040,"      Eu "+cCliente+",portador(a) da Cédula de Identidade RG n. "+cRG+",",oFont08 )   
			oPrint:Say(420,0040,"      CPF/MF n. "+cCPF+" , residente  e  domiciliado(a)  na "+cEnd+", CEP ",oFont08 )   
		    oPrint:Say(470,0040,"      "+cCep+" ,   Bairro   "+cBairro+" ,  Município   de  "+cMun+" ,  Estado  de "+cEst+",",oFont08 )   
		    oPrint:Say(520,0040,"      tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Elseif cPessoa == "J"
			oPrint:Say(370,0040,"      Eu  "+cCliente+", portador(a) do CNPJ n. "+cCPF+", residente  e domici-",oFont08 )   
		    oPrint:Say(420,0040,"      liado(a) na "+cEnd+",CEP "+cCep+", Bairro "+cBairro+",",oFont08 )   
		    oPrint:Say(470,0040,"      Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Else
			oPrint:Say(370,0040,"      Eu  "+cCliente+" , portador(a)  da  do   documento  n. "+space(20)+" ,",oFont08 )   
			oPrint:Say(420,0040,"      residente   e    domiciliado(a)    na  "+cEnd+" , CEP "+cCep+" ,   Bairro",oFont08 )   
		    oPrint:Say(470,0040,"      "+cBairro+", Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Endif
		//oPrint:Say(420,0040,"      inscrito(a)     no   CPF/MF    sob    o   n.      "+cCPF+" ,    residente   e   domiciliado(a)    na",oFont08 )   
		//oPrint:Say(470,0040,"       "+cEnd+",CEP "+cCep+", Bairro "+cBairro+", Município de",oFont08 )   
		//oPrint:Say(520,0040,"      "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		
		oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de      "+dtoc(dData)+"  ,   para a   empresa  ",oFont08 )
		oPrint:Say(660,0040,"      "+cConcAtu+" ,  o   veículo  marca  "+cMarca+" , modelo "+cDesMod+",",oFont08 )   
		oPrint:Say(710,0040,"      Ano/Modelo   "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,   placa "+cPlaca+" ,  motor "+cNumMot+",",oFont08 )   
		oPrint:Say(760,0040,"      chassi "+cChassi+" , KM constante   nesta  data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual  será entregue  à",oFont08 )   
		oPrint:Say(810,0040,"      referida  empresa livre e desembaraçado  de  quaisquer ônus  ou  restrições à "+cConcAtu+", bem como a",oFont08 )   
		oPrint:Say(860,0040,"      cópia da minha CNH(Carteira Nacional de Habilitação),em anexo.",oFont08 )   
		//oPrint:Say(910,0040,"      ,oFont08 )   
	Else
		if cPessoa == "F"
			oPrint:Say(370,0040,"      Eu "+cCliente+",portador(a) da Cédula de Identidade RG n. "+cRG+",",oFont08 )   
			oPrint:Say(420,0040,"      CPF/MF n. "+cCPF+" , residente  e  domiciliado(a)  na "+cEnd+", CEP ",oFont08 )   
		    oPrint:Say(470,0040,"      "+cCep+" ,   Bairro   "+cBairro+" ,  Município   de  "+cMun+" ,  Estado  de "+cEst+",",oFont08 )   
		    oPrint:Say(520,0040,"      tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Elseif cPessoa == "J"
			oPrint:Say(370,0040,"      Eu  "+cCliente+", portador(a) do CNPJ n. "+cCPF+", residente  e domici-",oFont08 )   
		    oPrint:Say(420,0040,"      liado(a)  na   "+cEnd+" ,  CEP  "+cCep+" ,   Bairro "+cBairro+",",oFont08 )   
		    oPrint:Say(470,0040,"      Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Else
			oPrint:Say(370,0040,"      Eu  "+cCliente+" , portador(a)  da  do   documento  n. "+space(20)+" ,",oFont08 )   
			oPrint:Say(420,0040,"      residente   e    domiciliado(a)    na  "+cEnd+" , CEP "+cCep+" ,   Bairro",oFont08 )   
		    oPrint:Say(470,0040,"      "+cBairro+", Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		Endif
		//oPrint:Say(420,0040,"      inscrito(a)     no   CPF/MF    sob    o   n.      "+cCPF+" ,    residente   e   domiciliado(a)    na",oFont08 )   
		//oPrint:Say(470,0040,"       "+cEnd+",CEP "+cCep+", Bairro "+cBairro+", Município de",oFont08 )   
		//oPrint:Say(520,0040,"      "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
		
		oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de      "+dtoc(dData)+"  ,   para a   empresa  ",oFont08 )
		oPrint:Say(660,0040,"      "+cConcAtu+" ,  o   veículo  marca  "+cMarca+" , modelo "+cDesMod+",",oFont08 )   
		oPrint:Say(710,0040,"      Ano/Modelo   "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,   placa "+cPlaca+" ,  motor "+cNumMot+",",oFont08 )   
			oPrint:Say(760,0040,"      chassi "+cChassi+" , KM  constante   nesta   data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual  será entregue  à",oFont08 )   
		oPrint:Say(810,0040,"      referida  empresa livre e desembaraçado  de  quaisquer ônus  ou  restrições à "+Alltrim(cConcAtu)+".",oFont08 )   
//		oPrint:Say(860,0040,"      cópia da minha CNH(Carteira Nacional de Habilitação),em anexo.",oFont08 )   
		//oPrint:Say(910,0040,"      ,oFont08 )   
	Endif	 
Else
	if cRotina == "1"      
		if cPessoa == "F"
			oPrint:Say(370,0040,"      Eu "+cCliente+",portador(a) da Cédula de Identidade RG n. "+cRG+",",oFont08 )   
			oPrint:Say(420,0040,"      CPF/MF n. "+cCPF+" , residente  e  domiciliado(a)  na "+cEnd+", CEP ",oFont08 )   
		    oPrint:Say(470,0040,"      "+cCep+" ,   Bairro   "+cBairro+" ,  Município   de  "+cMun+" ,  Estado  de "+cEst+",",oFont08 )   
		    oPrint:Say(520,0040,"      tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de     "+dtoc(dData)+"  ,   para a  empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o   veículo   marca   "+cMarca+" , modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será entregue  à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+cConcAtu+" bem como a cópia da minha CNH(Carteira Nacional de Habilitação),",oFont08 )   
			oPrint:Say(910,0040,"      em anexo.",oFont08 )   
		Elseif cPessoa == "J"
			oPrint:Say(370,0040,"      Eu  "+cCliente+", portador(a) do CNPJ n. "+cCPF+", residente  e domici-",oFont08 )   
		    oPrint:Say(420,0040,"      liado(a) na "+cEnd+",CEP "+cCep+", Bairro "+cBairro+",",oFont08 )   
		    oPrint:Say(470,0040,"      Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de     "+dtoc(dData)+"  ,   para a  empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o   veículo   marca   "+cMarca+" , modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será entregue  à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+Alltrim(cConcAtu)+".",oFont08 )   
//			oPrint:Say(910,0040,"      em anexo.",oFont08 )   
		Else
			oPrint:Say(370,0040,"      Eu  "+cCliente+" , portador(a)  da  do   documento  n. "+space(20)+" ,",oFont08 )   
			oPrint:Say(420,0040,"      residente   e    domiciliado(a)    na  "+cEnd+" , CEP "+cCep+" ,   Bairro",oFont08 )   
		    oPrint:Say(470,0040,"      "+cBairro+", Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de     "+dtoc(dData)+"  ,   para a  empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o   veículo   marca   "+cMarca+" , modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será entregue  à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+cConcAtu+" bem como a cópia da minha CNH(Carteira Nacional de Habilitação),",oFont08 )   
			oPrint:Say(910,0040,"      em anexo.",oFont08 )   
		Endif
		//oPrint:Say(420,0040,"      inscrito(a)     no   CPF/MF    sob    o   n.      "+cCPF+" ,    residente   e   domiciliado(a)    na",oFont08 )   
		//oPrint:Say(470,0040,"       "+cEnd+",CEP "+cCep+", Bairro "+cBairro+", Município de",oFont08 )   
		//oPrint:Say(520,0040,"      "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   
	Else
		if cPessoa == "F"
			oPrint:Say(370,0040,"      Eu "+cCliente+",portador(a) da Cédula de Identidade RG n. "+cRG+",",oFont08 )   
			oPrint:Say(420,0040,"      CPF/MF n. "+cCPF+" , residente  e  domiciliado(a)  na "+cEnd+", CEP ",oFont08 )   
		    oPrint:Say(470,0040,"      "+cCep+" ,   Bairro   "+cBairro+" ,  Município   de  "+cMun+" ,  Estado  de "+cEst+",",oFont08 )   
		    oPrint:Say(520,0040,"      tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de      "+dtoc(dData)+"  , para a   empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o  veículo   marca   "+cMarca+" ,  modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta  data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será  entregue à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+cConcAtu+" bem como a cópia da minha CNH(Carteira Nacional de Habilitação),",oFont08 )   
			oPrint:Say(910,0040,"      em anexo.",oFont08 )   

		Elseif cPessoa == "J"
			oPrint:Say(370,0040,"      Eu  "+cCliente+", portador(a) do CNPJ n. "+cCPF+", residente  e domici-",oFont08 )   
		    oPrint:Say(420,0040,"      liado(a)  na   "+cEnd+" ,  CEP  "+cCep+" ,   Bairro "+cBairro+",",oFont08 )   
		    oPrint:Say(470,0040,"      Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de      "+dtoc(dData)+"  , para a   empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o  veículo   marca   "+cMarca+" ,  modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta  data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será  entregue à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+Alltrim(cConcAtu)+".",oFont08 )    
	//		oPrint:Say(910,0040,"      em anexo.",oFont08 )   

		Else
			oPrint:Say(370,0040,"      Eu  "+cCliente+" , portador(a)  da  do   documento  n. "+space(20)+" ,",oFont08 )   
			oPrint:Say(420,0040,"      residente   e    domiciliado(a)    na  "+cEnd+" , CEP "+cCep+" ,   Bairro",oFont08 )   
		    oPrint:Say(470,0040,"      "+cBairro+", Município de "+cMun+", Estado de "+cEst+",tel.res ("+cDDD+")"+cTel+". ",oFont08 )   

			oPrint:Say(610,0040,"      DECLARO   para  todos   os  fins ,  ter   vendido   nesta   data   de      "+dtoc(dData)+"  , para a   empresa  ",oFont08 )
			oPrint:Say(660,0040,"      "+cConcAtu+" ,  o  veículo   marca   "+cMarca+" ,  modelo ",oFont08 )   
			oPrint:Say(710,0040,"      "+cDesMod+",Ano/Modelo  "+substr(cFabMod,1,4)+"/"+substr(cFabMod,5,8)+", cor "+cCor+" ,  placa "+cPlaca+" ,",oFont08 )   
			oPrint:Say(760,0040,"      motor "+cNumMot+", chassi "+cChassi+", KM constante nesta  data: "+Alltrim(str(cKilome))+space(len(str(cKilome))-len(Alltrim(str(cKilome))))+", o qual",oFont08 )   
			oPrint:Say(810,0040,"      será  entregue à  referida   empresa  livre  e  desembaraçado   de   quaisquer  ônus   ou   restrições  à ",oFont08 )   
			oPrint:Say(860,0040,"      "+cConcAtu+" bem como a cópia da minha CNH(Carteira Nacional de Habilitação),",oFont08 )   
			oPrint:Say(910,0040,"      em anexo.",oFont08 )   
		Endif
	Endif	 
Endif
oPrint:Say(1000,0040,"     DECLARO ainda:",oFont08 )  
 
oPrint:Say(1090,0040,"     1- Ser totalmente responsável pela boa procedência, kilometragem acima informada e pela  regulariedade dos",oFont08 )
oPrint:Say(1140,0040,"        documentos referentes ao veículo supra identificado, estando ciente de qualquer irregulariedade enseja-",oFont08 )
oPrint:Say(1190,0040,"        rá minha responsabilidade na esfera  cível e criminal , com relação a multas de trânsito , pagamento de",oFont08 )
oPrint:Say(1240,0040,"        IPVA, Seguro Obrigatório, Bloqueios Judiciais e Administrativos  e entre outros débitos de qualquer na-",oFont08 )
oPrint:Say(1290,0040,"        tureza mesmo que por ventura sejam lançados posteriormente após a data de entrega do veículo "+dtoc(dData)+".",oFont08 )

oPrint:Say(1380,0040,"     2- Responsabilizo-me ainda por arcar com despesa  e  encargos decorrentes de eventual exercício de direito",oFont08 )
oPrint:Say(1430,0040,"        de  regresso pela "+cConcAtu+"  caso recaia sobre o  bem qualquer",oFont08 )
oPrint:Say(1480,0040,"        restrição, dívida e/ou ônus que inviabilize a tranferência do veículo a terceiro  adquirente , bem como",oFont08 )        
oPrint:Say(1530,0040,"        comprometo-me a pagar assim que cientificado para tal fim.",oFont08 )        

oPrint:Say(1620,0040,"     3- Conforme a lei n.14.717, de 17 de abril de 2.008 foi introduzido as alterações na lei  n. 11.733, sendo",oFont08 )
oPrint:Say(1670,0040,"        assim  me responsabilizo pela  vistoria que será realizada  posteriormente a esta data no referido veí-",oFont08 )
oPrint:Say(1720,0040,"        culo, através de empresa credenciada  ao órgão competente  que efetuará a  inspeção ambiental, de forma",oFont08 )
oPrint:Say(1770,0040,"        o veículo não seja aprovado, estou ciente de que  a "+cConcAtu+",",oFont08 )
oPrint:Say(1820,0040,"        que caso poderá cobrar-me com as despesas que houver para a devida regularização , conforme autorização",oFont08 )
oPrint:Say(1870,0040,"        na cláusula abaixo.",oFont08 )

oPrint:Say(1960,0040,"     4- Autorizo a "+cConcAtu+", a emitir boleto bancário através de ins-",oFont08 )
oPrint:Say(2010,0040,"        tituição financeira, independentemente de prévia  notificação , para promover o  pagamento de eventuais",oFont08 )
oPrint:Say(2060,0040,"        débitos existentes no referido  veículo, e posteriormente caso seja necessário, efetuar  as respectivas",oFont08 )
oPrint:Say(2110,0040,"        cobranças de valores por ela pagos, e em caso de não  pagamento da referida cobrança, autorizo a  mesma",oFont08 )
oPrint:Say(2160,0040,"        a o protesto em cartório, com o fim de ressarcimento pela prévia quitação, mesmo em caso  de recurso em",oFont08 )
oPrint:Say(2210,0040,"        andamento  e  pendente de julgamento. Outrossim , me  comprometo a entregar  em tempo  hábil a  Conces-",oFont08 )
oPrint:Say(2260,0040,"        sionária/Loja qualquer documento e/ou cobrança que por ventura receber em meu endereço para que a mesma",oFont08 )
oPrint:Say(2310,0040,"        tome as devidas providências.",oFont08 )
oPrint:Say(2360,0040,"        4.1 - Estar  ciente que não devo pagar qualquer débito aos orgãos  publicos  após a venda  do  veículo,",oFont08 )
oPrint:Say(2410,0040,"        sem  autorização expressa da "+cConcAtu+",  pois  não  ressarcido",oFont08 )
oPrint:Say(2460,0040,"        no caso de optar por realizar o pagamento prévio sem comunicá-la e /ou sem  autorização,  bem  como  em",oFont08 )
oPrint:Say(2510,0040,"        em caso de efetuado por mim e pela "+cConcAtu+", fico responsável ",oFont08 )
oPrint:Say(2560,0040,"        pelo  ressarcimento  dos valores pagos pela mesma, tendo em vista que a  empresa irá  quitar  todos  os",oFont08 )
oPrint:Say(2610,0040,"        débitos  existentes após  a  venda para a mesma  e  irá cobrar posteriormente, onde me comprometo a dar",oFont08 )
oPrint:Say(2660,0040,"        quitação dos referidos débitos.",oFont08 )
oPrint:EndPage() 
oPrint:StartPage() 		// Inicia uma nova pagina

oPrint:Say(0370,0040,"     5- Estar ciente que no caso do não pagamento e da necessidade de proposítura de ação judicial, será cobra-",oFont08 )
oPrint:Say(0420,0040,"        do o valor principal  do crédito acrescido de  multa de  10% (dez por cento) a  título de processamento",oFont08 )
oPrint:Say(0470,0040,"        administrativo e despesas com despachante, juros de mora 1% (um por cento) ao mês e correção monetária,",oFont08 )
oPrint:Say(0520,0040,"        sujeitando-me ainda ao pagamento  de  custas e despesas  processuais, além de verba honorária fixada em",oFont08 )
oPrint:Say(0570,0040,"        20% (vinte por cento) sobre o valor da causa.",oFont08 )

oPrint:Say(0660,0040,"     6- Outorgar poderes  para  que a "+cConcAtu+",  possa  indicar-me como",oFont08 )
oPrint:Say(0710,0040,"        condutor/infrator nos casos de multa de trânsito, oriundas praticadas no período anterior às "+(Substr(Time(),1,2)+":"+Substr(Time(),4,2))+" horas",oFont08 )
oPrint:Say(0760,0040,"        do dia "+dtoc(ddatabase)+", horário e data de entrega do veículo devidamente identificado neste Termo  de  Responsa-",oFont08 )
oPrint:Say(0810,0040,"        bilidade, nos termos do artigo 257. parágrafo 7 e 8 do Código de Trânsito Brasileiro.",oFont08 )

oPrint:Say(0900,0040,"     7- Estar ciente e concordar que a propositura  de eventual  recurso, bem como  qualquer discussão  sobre a",oFont08 )
oPrint:Say(0950,0040,"        procedência ou improcedência das multas de trânsito deverá por mim ser feita ao orgão  autuador, segundo",oFont08 )
oPrint:Say(1000,0040,"        os meus critérios e expensas,e em nenhuma hipótese com a "+cConcAtu,oFont08 )
oPrint:Say(1050,0040,"        ,  bem  como  estar  ciente  que   no  caso  de  procedência  do  recurso   por   mim   interposto ,  a",oFont08 )
oPrint:Say(1100,0040,"        "+cConcAtu+" , me  repassará  a  Guia  paga  para  que   eu  possa",oFont08 )
oPrint:Say(1150,0040,"        solicitar ao orgão o reembolso  do valor pago a título de restituição, bastando cientifica-la com prazo",oFont08 )
oPrint:Say(1200,0040,"        hábil para fornecer a referida documentação.",oFont08 )

oPrint:Say(1290,0040,"     8- Comprometo-me  a assinar  ou indicar o responsável  e/ou entregar enventual  infração  de  trânsito com",oFont08 )
oPrint:Say(1340,0040,"        antecedência mínima de 10 (dez) dias, sendo totalmente responsável civil e criminalmente  por pontuação",oFont08 )
oPrint:Say(1390,0040,"        indevida e injustamente inserida em Carteira Nacional de Habilitação de terceiro adquirente.",oFont08 )

oPrint:Say(1480,0040,"     Por ser verdade, firmo o presente instrumento, em 02 (duas) folhas",oFont08 )

oPrint:Say(1780,0040,"                   _________________________,______de___________________de 20_____.",oFont08 )

oPrint:Say(2080,0040,"        "+space(30)+"_____________________________________           ",oFont08 )
oPrint:Say(2130,0040,"        "+space(30)+cCliente,oFont08 )
if cPessoa == "F"
	oPrint:Say(2180,0040,"        "+space(30)+"CPF: "+cCPF,oFont08 )
Elseif cPessoa == "J"
	oPrint:Say(2180,0040,"        "+space(30)+"CNPJ: "+cCPF,oFont08 )
Else
	oPrint:Say(2180,0040,"        "+space(30)+"Documento n.: ",oFont08 )
Endif
oPrint:Say(2380,0040,"        _____________________________________           ",oFont08 )
oPrint:Say(2430,0040,"        Testemunha 01",oFont08 )
oPrint:Say(2480,0040,"        Nome: ",oFont08 )
if cPessoa == "F"
	oPrint:Say(2530,0040,"        CPF: ",oFont08 )
Elseif cPessoa == "J"
	oPrint:Say(2530,0040,"        CNPJ: ",oFont08 )
Else
	oPrint:Say(2530,0040,"        Documento n.: ",oFont08 )
Endif
oPrint:Say(2380,0040,"        "+space(50)+"_____________________________________           ",oFont08 )
oPrint:Say(2430,0040,"        "+space(50)+"Testemunha 02",oFont08 )
oPrint:Say(2480,0040,"        "+space(50)+"Nome: ",oFont08 )
if cPessoa == "F"
	oPrint:Say(2530,0040,"        "+space(50)+"CPF: ",oFont08 )
Elseif cPessoa == "J"
	oPrint:Say(2530,0040,"        "+space(50)+"CNPJ: ",oFont08 )
Else	
	oPrint:Say(2530,0040,"        "+space(50)+"Documento n.: ",oFont08 )
Endif
Return Nil

