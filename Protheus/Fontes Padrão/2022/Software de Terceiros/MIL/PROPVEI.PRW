/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PROPVEI  ³ Autor ³  Manoel               ³ Data ³ 29/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia da Proposta de Venda de Veiculos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  - (Veiculos)                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION PROPVEI()

Local nCntFor, i
Private lVAMCid := GetNewPar("MV_CADCVAM","N") == "S"

SetPrvt("aDriver,cTitulo,cNomProg,Limite,cCabec1,cCabec2,cNomeImp,lServer,cTamanho,m_Pag,nLin,cAlias,aReturn,cNumPed")
SetPrvt("aErrAva,cCodMap,bCampo,cCpoDiv,aStru")

aStru    := {}
cCpoDiv  := "    1"
bCampo   := { |nCPO| Field(nCPO) }
cCodMap  := "001"
aErrAva  := {}
cNumPed  := ParamIxb[1]
cTamanho := "P"           // P/M/G
nCaracter:= 18            // 20 - Normal     -   15 - Compactado
Limite   := 80            // 80/132/220
aOrdem   := {}           // Ordem do Relatorio
cTitulo  := "Proposta / Pedido de Venda"
nLastKey := 0
aReturn  := { "Zebrado", 1,"Administracao", 2, 1, 1, "",1 }
cNomProg := "PROPVEI"
cNomeRel := "PROPVEI"
aDriver := LeDriver()
cCompac := aDriver[1]
cNormal := aDriver[2]
cDrive   := "Epson.drv"
cNomeImp := "LPT1"
cAlias   := "VV1"
cCabec1  := ""
cCabec2  := ""
lHabil   := .f.
Inclui   := .f.
m_Pag    := 1
cRodape  := ""
cRodape1 := Alltrim(Subs(cRodape,001,070))
cRodape2 := Alltrim(Subs(cRodape,071,070))
cRodape3 := Alltrim(Subs(cRodape,141,070))
cRodape4 := Alltrim(Subs(cRodape,211,070))
/*
[1] Reservado para Formulario
[2] Reservado para nro de Vias
[3] Destinatario
[4] Formato => 1-Comprimido 2-Normal
[5] Midia   => 1-Disco 2-Impressora
[6] Porta ou Arquivo 1-LPT1... 4-COM1...
[7] Expressao do Filtro
[8] Ordem a ser selecionada
[9]..[10]..[n] Campos a Processar (se houver)
*/

cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.F.,cTamanho,nil    ,nil    ,nil)
If nLastKey == 27
	Set Filter To
	Return
Endif
SetDefault(aReturn,cAlias)

Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

cNomEmp := SM0->M0_NOME
cCGCFil := transform(left(SM0->M0_CGC,14),"@R 99.999.999/9999-99")
cEndEmp := left(SM0->M0_ENDENT,30)
cCEPFil := transform(SM0->M0_CEPENT,"@R 99999-999")
cInMFil := transform(SM0->M0_CODMUN,"@R 999.999/9")
cTelFil := SM0->M0_TEL
cFaxFil := SM0->M0_FAX
cInsFil := SM0->M0_INSC
cCidFil := SM0->M0_CIDENT
cEstFil := SM0->M0_ESTENT
cBaiFil := SM0->M0_BAIRENT

VV9->(dbSetOrder(1))
VV9->(DBSEEK(XFILIAL("VV9")+VV0->VV0_NUMTRA))
VVA->(dbSetOrder(1))
VVA->(DBSEEK(XFILIAL("VVA")+VV0->VV0_NUMTRA))
VV1->(DBSEEK(XFILIAL("VV1")+VVA->VVA_CHAINT))
VV2->(DBSEEK(XFILIAL("VV2")+VV1->VV1_CODMAR+VV1->VV1_MODVEI))
VVC->(DBSEEK(XFILIAL("VVC")+VV1->VV1_CODMAR+VV1->VV1_CORVEI))
SA1->(dbSetOrder(1))
SA1->(DBSEEK(XFILIAL("SA1")+VV9->VV9_CODCLI+VV9->VV9_LOJA))
SA3->(DBSEEK(XFILIAL("SA3")+VV0->VV0_CODVEN))
VVT->(DBSEEK(XFILIAL("VVT")+VV0->VV0_NUMTRA))
VE1->(DBSEEK(XFILIAL("VE1")+VV1->VV1_CODMAR))
SE4->(DBSEEK(XFILIAL("SE4")+VV0->VV0_FORPAG))
If lVAMCid
	VAM->(DBSEEK(xFilial("VAM")+SA1->A1_IBGE))
EndIf
VV3->(DBSEEK(xFilial("VV3")+VV0->VV0_TIPVEN))

DbSelectArea("VV0")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

DbSelectArea("VVA")
DbSeek(xFilial("VVA")+M->VV0_NUMTRA)
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

for i:= 1 to 7
	
	cKeyAce := VV9->VV9_OBSMEM + strzero(i,3)
	cCampo  := "cObserv"+STR(i,1)
	
	DbSelectArea("SYP")
	DbSetOrder(1)
	if DbSeek(xfilial("SYP") + cKeyAce )
		
		nPos1 := AT("\13\10",SYP->YP_TEXTO)
		if nPos1 > 0
			nPos := len(alltrim(SYP->YP_TEXTO)) - 6
		else
			nPos := len(alltrim(SYP->YP_TEXTO))
		endif
		
		&cCampo := Substr(SYP->YP_TEXTO,1,nPos)
		
	Else
		&cCampo := " "
		
	Endif
	
next

nLin      := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter) + 1
cCGCCPF1  := subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1)
cCGCCPF   := cCGCCPF1 + space(18-len(cCGCCPF1))

@ nLin,00 psay repl("-",80)
nLin++
if VV0->VV0_OPEMOV <> "1"
   @ nLin,00 psay "               P r o p o s t a   d e   V e n d a  /  P e d i d o"
Else   
   @ nLin,00 psay "                      S i m u l a c a o  d e   V e n d a "
Endif

nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin, 00 psay "Empresa.....: " + left(cNOMEMP,37) + " CNPJ: " + cCGCFIL  //+ " I.E.: " + cINSFIL
nLin++
@ nLin, 00 psay "Endereco....: " + cENDEMP + "        Bairro...: " + cBAIFIL 
nLin++
@ nLin, 00 psay "Telefone....: " + cTELFIL + space(24) + "Fax.....: " + cFaxFil
nLin++
@ nLin, 00 psay "Cidade......: " + cCIDFIL + " - "  + cESTFIL+ space(13) + "CEP.....: " + cCEPFIL
//nLin++
//@ nLin, 00 psay "CNPJ........: " + cCGCFIL + "      Inscricao Estadual: " + cINSFIL
nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin,00 psay "Data........: " + dToc(VV0->VV0_DATMOV)   + Space(30) + "Atendimento..: " + VV9->VV9_NUMATE
nLin++
@ nLin,00 psay "Vendedor....: " + VV0->VV0_CODVEN + " - "  + Subs(SA3->A3_NOME,1,30) 

nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin,00 psay "Cliente.....: " + left(SA1->A1_NOME,36) + space(2) + "CNPJ/CPF: " + cCGCCPF
nLin++
@ nLin,00 psay "Endereco....: " + left(SA1->A1_END,36)  + space(2) + "Bairro..: " + SA1->A1_BAIRRO
nLin++
If lVAMCid
	@ nLin,00 psay "Cidade......: " + left(VAM->VAM_DESCID,25) + " - " + VAM->VAM_ESTADO + space(8) + "CEP.....: " + transf(SA1->A1_CEP,"@R 99999-999")
	nLin++
	@ nLin,00 psay "Telefone Res: " + "(" + VAM->VAM_DDD + ") " + TRANSF(SA1->A1_TEL, "@r 9999-9999") 
Else
	@ nLin,00 psay "Cidade......: " + left(SA1->A1_MUN,25) + " - " + SA1->A1_EST + space(8) + "CEP.....: " + transf(SA1->A1_CEP,"@R 99999-999")
	nLin++
	@ nLin,00 psay "Telefone Res: " + "(" + SA1->A1_DDD + ") " + TRANSF(SA1->A1_TEL, "@r 9999-9999")
EndIf
nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin,00 psay "Chassi......: " + VVA->VVA_CHASSI 
@ nLin,53 psay "Marca: " + VE1->VE1_DESMAR
nLin++
@ nLin,00 psay "Modelo......: " + VV2->VV2_DESMOD 
@ nLin,53 psay "Cor..: " + Subs(VVC->VVC_DESCRI,1,14)
nLin++
@ nLin,00 psay "Ano/Mod.....: " + Subs(VV1->VV1_FABMOD,1,4) + "/" + Subs(VV1->VV1_FABMOD,5,4)
@ nLin,53 psay IIF(VV1->VV1_ESTVEI == "1","VEICULO USADO Km: "+STRZERO(VV1->VV1_KILVEI,8),"VEICULO NOVO")

nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin,00 psay "Valor ............................................." + transform(VV0->VV0_VALMOV,"@E 999,999,999.99")

nLin++
@ nLin,00 psay repl("-",80)

nTotAce := 0

if VVT->VVT_VALEQP > 0
   nLin++
   @ nLin,00 psay "Acessorios"
	nLin := nLin + 2
	@ nLin,00 psay "Grupo Codigo do Acessorio         Descricao do Acessorio                  Valor"
endif

DbSelectArea("VVT")
while VVT->VVT_FILIAL == xFilial("VVT") .and. VVT->VVT_NUMTRA == VV0->VV0_NUMTRA .and. !eof()

	if VVT->VVT_VALEQP > 0   
	
		if nLin > 53
			nLin     := cabec(ctitulo,cCabec1,cCabec2,cnomprog,ctamanho,nCaracter) + 1
			nLin++
			@ nLin,00 psay "Acessorios"
			nLin := nLin + 2
			@ nLin,00 psay "Grupo Codigo do Acessorio         Descricao do Acessorio                  Valor"
			nLin++
		Endif         
	
		SB1->(DBSEEK(XFILIAL("SB1")+VVT->VVT_GRUITE+VVT->VVT_CODITE))
		@ nLin++,00 psay VVT->VVT_GRUITE + "  " +  VVT->VVT_CODITE + " " + SB1->B1_DESC + "  " +  transform(VVT->VVT_VALEQP,"@E 99,999,999.99")
		nTotAce := nTotAce + VVT->VVT_VALEQP

	endif
	
		DbSelectArea("VVT")
		dbSkip()

Enddo

if nTotAce > 0
   nLin++
   @ nLin,42 psay "Total de Acessorios     " + transform(nTotAce,"@E 99,999,999.99")
   nLin ++
   @ nLin,00 psay repl("-",80)
endif

nLin++
@ nLin,00 psay "Forma de Pagamento: "  + VV0->VV0_FORPAG + " - " + SE4->E4_DESCRI
nLin++

cDecl := "SEM RESTRICOES"

if !EMPTY(VV0->VV0_CBCOAA)
	DbSelectArea("VV3")
	DbSetOrder(1) 
	DbSeek( xFilial("VV3") + VV0->VV0_TIPVEN )
    //
	if VV0->VV0_CATVEN = "3" // CDC
		DbSelectArea("SA6")
		DbSetOrder(1) 
		DbSeek( xFilial("SA6") + VV0->VV0_CBCOAA + VV0->VV0_ABCOAA )
		cDecl := "FATURADO C/ CLAUSULA ALIEN. FIDUCIARIA A FAVOR DE "+Alltrim(SA6->A6_NOME)
	elseif VV0->VV0_CATVEN $ "56" // CONSORCIO PROPRIO / OUTROS
		DbSelectArea("SA6")
		DbSetOrder(1) 
		DbSeek( xFilial("SA6") + VV0->VV0_CBCOAA + VV0->VV0_ABCOAA )
		cDecl := "FATURADO C/ CLAUSULA DE ALIEN. A FAVOR DE "+Alltrim(Left(SA6->A6_NOME,30))
	elseif VV0->VV0_CATVEN == "7"
		DbSelectArea("SA1")
		DbSetOrder(1) 
		DbSeek( xFilial("SA1") + VV0->VV0_CODCLI + VV0->VV0_LOJA )
		cNom  := Alltrim(Left(SA1->A1_NOME,35))
		cCGCCPF2 := subs(transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))),1,at("%",transform(SA1->A1_CGC,PicPes(RetPessoa(SA1->A1_CGC))))-1)
		cCid     := Alltrim(SA1->A1_MUN)
		cEst     := SA1->A1_EST
		cIns     := SA1->A1_INSCR
		cRg      := SA1->A1_PFISICA
		cCep     := SA1->A1_CEP
		cEnd     := Alltrim(SA1->A1_END)//+", "+Alltrim(SA1->A1_NUMERO)
		cFon     := SA1->A1_TEL
		cDecl := "ARRENDADO PARA:" + Alltrim(Left(SA1->A1_NOME,35))
	elseif VV3->VV3_TIPVEN = "CR"
		cDecl := "COM RESERVA DE DOMINIO A FAVOR DE "+ alltrim(SM0->M0_NOMECOM)
	endif
endif

@ nLin,00 psay Left(cDecl,79)
nLin++

@ nLin,00 psay "Tipo de Pagamento    Nro Documento      Data           Valor"

DbSelectArea("VS9")
DBSEEK(xfilial("VS9")+VV0->VV0_NUMTRA+'V')

while !eof() .and. VS9->VS9_NUMIDE+VS9->VS9_TIPOPE == VV0->VV0_NUMTRA+"V"
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(xfilial("SX5") + '05'+VS9->VS9_TIPPAG ) 

   nLin++	
	
	if nLin > 53
		nLin := cabec(ctitulo,cCabec1,cCabec2,cnomprog,ctamanho,nCaracter) + 1
		@ nLin,00 psay "Forma de Pagamento: "+ VV0->VV0_FORPAG + " - " + SE4->E4_DESCRI
		nLin++
		@ nLin,00 psay "Tipo de Pagamento    Nro Documento      Data           Valor"
		nLin++
	Endif
	
	@ nLin,00 psay VS9->VS9_TIPPAG + "-" + subs(SX5->X5_DESCRI,1,13) + Space(5) + VS9->VS9_REFPAG + Space(2) + dToc(VS9->VS9_DATPAG) + " " + transform(VS9->VS9_VALPAG,"@E 99,999,999.99")
	
	if !empty(VS9->VS9_OBSMEM)
		nLin++		
		@ nLin,00 psay E_MSMM(VS9->VS9_OBSMEM,80)
  	endif
	
	DbSelectArea("VS9")
	DbSkip()
	
Enddo

nLin++
@ nLin,00 psay repl("-",80)
nLin++
@ nLin,00 psay "Observacoes:"
nLin++
@ nLin,00 psay cObserv1
nLin++
@ nLIn,00 psay cObserv2
nLin++
@ nLin,00 psay cObserv3
nLin++
@ nLin,00 psay cObserv4
nLin++
@ nLin,00 psay cObserv5
nLin++
@ nLin,00 psay cObserv6
nLin++
@ nLin,00 psay cObserv7

if VV0->VV0_OPEMOV <> "1"
	nLin++
	@ nLin,00 psay repl("-",80)
	nLin++
	@ nLin,00 psay "Faturado em: ___/___/____                           Nota Fiscal: "
	nLin++
	@ nLin,00 psay repl("-",80)

	nLin := nLin + 1

	if nLin < 50
	
		nLin := 50
	
	   @ nLin,01 psay "Autorizo o faturamento nas condicoes expressas desta proposta."
	   nLin := nLin + 5
		@ nLin,01 psay "___/___/____        ___________________            ________________________"
		nLin++
		@ nLin,01 psay "                    Vendedor                       Assinatura do Proponente"
		nLin := nLin + 2
		@ nLin,00 psay padc(cRodape1,80)
		nLin++
		@ nLin,00 psay padc(cRodape2,80)
		nLin++
		@ nLin,00 psay padc(cRodape3,80)
		nLin++
		@ nLin,00 psay padc(cRodape4,80)
	
	else
	
   	@ nLin,01 psay "Autorizo o faturamento nas condicoes expressas desta proposta."
	   nLin := nLin + 5
		@ nLin,01 psay "___/___/____        ___________________            ________________________"
		nLin++
		@ nLin,01 psay "                         Vendedor                  Assinatura do Proponente" 
		nLin := nLin + 2
		@ nLin,00 psay padc(cRodape1,80)
		nLin++
		@ nLin,00 psay padc(cRodape2,80)
		nLin++
		@ nLin,00 psay padc(cRodape3,80)
		nLin++
		@ nLin,00 psay padc(cRodape4,80)
	
	endif
endif

/*
//Avaliacao da Venda
FG_CalcVlrs(FS_VDRVM050(VV0->VV0_TIPFAT,cCodMap))

nLin := 1
@nLin,00 psay "| Titulo da Conta                       Valores em R$        %           Valores em MF        %          Valor Presente       %    |"
nLin++
@ nLin,00 psay repl("-",132)
nLin := nLin + 1
@ nLin,00 psay "|"
nLin := nLin + 1
For vv = 1 to len(aStru)
	@ nLin,00 psay "| " + If(Left(aStru[vv,05],7)==Space(7),Space(3)+Ltrim(aStru[vv,05]),aStru[vv,05]+Space(3)) + Space(6) + transform(aStru[vv,09],"@E 9,999,999.99")+Space(6)+transform(aStru[vv,10],"@E 999.99")+Space(9)+transform(aStru[vv,12],"@E 9,999,999.99")+;
	Space(6)+transform(aStru[vv,13],"@E 999.99")+Space(9)+transform(aStru[vv,20],"@E 9,999,999.99")+Space(5)+transform(aStru[vv,21],"@E 999.99") + " |"
Next
 
*/


Ms_Flush()

Set Printer to
Set Device  to Screen

if aReturn[5] == 1
	OurSpool(cNomeRel)
Endif

Return
