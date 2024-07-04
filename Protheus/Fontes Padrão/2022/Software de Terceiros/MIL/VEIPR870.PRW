#INCLUDE "veipr870.ch"
#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ VEIPR870 ³ Autor ³ Andre                 ³ Data ³ 22/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Boleto de Pagamento das Parcelas do VIP                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Grupo VIP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIPR870

Local i  := 0
cAlias   := "VP3"
cNomRel  := "BOLETO"
cPerg    := "VPR870"
cTitulo  := STR0001 //"Emissao do Boleto de Pagamento"
cDesc1   := STR0001 //"Emissao do Boleto de Pagamento"
aOrdem   := {STR0002} //"Grupo+Cota"
lHabil   := .f.
cTamanho := "P"
nOpca    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Ambientais                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aReturn  := { OemToAnsi(STR0003), 1,OemToAnsi(STR0004), 2, 2, 2,,1 }  //### //"Zebrado"###"Administracao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Pergunte("VPR870",.t.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Grupo Inicial                            ³
//³ mv_par02        //  Grupo Final                              ³
//³ mv_par03        //  Cota Inicial                             ³
//³ mv_par04        //  Cota Final                               ³
//³ mv_par05        //  Mes/Ano                                  ³
//³ mv_par06        //  Banco 1-Banco do Brasil,2-Bradesco,3-Itau³
//³ mv_par07        //  Observacao1 do boleto                    ³
//³ mv_par08        //  Observacao2 do boleto                    ³
//³ mv_par09        //  Observacao3 do boleto                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cbTxt    := Space(10)
cbCont   := 0
cString  := "VP3"
Li       := 80
m_Pag    := 1
wnRel    := "BOLETO"
cTitulo  := STR0001 //"Emissao do Boleto de Pagamento"
cabec1   := ""
cabec2   := ""
nomeprog := "VEIR870"
tamanho  := "M"
nCaracter:= 18
//nLin     := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
NomeRel := SetPrint(cAlias,cNomRel,cPerg,@cTitulo,cDesc1,,,lHabil,,,cTamanho)

if nLastKey == 27
	Return
Endif                                

Pergunte(cPerg,.f.)

nTipo := If(aReturn[4]==1,15,18)

aClientes := {}
DbSelectArea("VP1")
DbSetOrder(1)
DbGotop()
DbSeek(xFilial("VP1")+mv_par01)
Do while !EOF() .and. (VP1_CODGRU >=  mv_par01 .and. VP1_CODGRU <= mv_par02)
	if mv_par01 == mv_par02
		if !(VP1_NUMCOT > mv_par03 .and. VP1_NUMCOT < mv_par04)
			Exit
		Endif
	Endif
	DbSelectArea("SA1")
	DbGotop()
	if DbSeek(xFilial("SA1")+VP1->VP1_CODCLI)  
	   if lA1_IBGE
	   	FG_Seek("VAM","SA1->A1_IBGE",1,.f.)
	   endif
	   DbSelectArea("VP2")
	   DbGotop()
       if DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI)
	      Do While !EOF() .and. (VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI == mv_par01+mv_par03+VP1->VP1_CODCLI)
		     if strzero(Month(VP2_DATPAR),2)+"/"+strzero(year(VP2_DATPAR),4) == mv_par05
         	    aadd(aClientes,{VP1->VP1_CODGRU,;
                                 VP1->VP1_NUMCOT,;
                                 VP1->VP1_CODCLI,;
            		             SA1->A1_NOME,;
          		                 SA1->A1_END,;
          		                 iif(lA1_IBGE,VAM->VAM_DESCID,SA1->A1_MUN),;
         		                 iif(lA1_IBGE,VAM->VAM_ESTADO,SA1->A1_EST),;
               					 VP2_NUMBOL,;
               					 VP2_CODGRU,;
               					 VP2_NUMCOT,;
               					 VP2_CODCLI,;
               					 VP2_NUMPAR,;
               					 VP2_DATPAR,;
               					 VP2_VALPAR,;
               					 VP2_VALDES,;
               					 VP2_VALPAR+VP2_VALDES,;
               					 VP1->VP1_OBSER1,;
               					 VP1->VP1_OBSER2})
	                             Exit
			 Endif   
        dbSkip()
		  Enddo
	   Endif
	Endif
	DbSelectArea("VP1")
	DbSkip()
Enddo

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set Device  to Printer

if mv_par06 == 1  // Banco do Brasil

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,13]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,035  pSay aClientes[i,8]

		@ nLin + 007,062  pSay aClientes[i,16]
		@ nLin + 009,002  pSay mv_par07
		@ nLin + 010,002  pSay mv_par08
		@ nLin + 011,002  pSay mv_par09
		@ nLin + 012,002  pSay aClientes[i,17]
		@ nLin + 013,002  pSay aClientes[i,18]

		@ nLin + 014,002  pSay aClientes[i,3]
		@ nLin + 014,010  pSay aClientes[i,4]
		@ nLin + 015,002  pSay aClientes[i,5]
		@ nLin + 015,045  pSay aClientes[i,6]
		@ nLin + 015,070  pSay aClientes[i,7]

      Eject

	Next

Elseif mv_par06 == 2  // Bradesco

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,13]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,035  pSay aClientes[i,8]

		@ nLin + 007,062  pSay aClientes[i,9]
		@ nLin + 009,002  pSay mv_par07
		@ nLin + 010,002  pSay mv_par08
		@ nLin + 011,002  pSay mv_par09
		@ nLin + 012,002  pSay aClientes[i,17]
		@ nLin + 013,002  pSay aClientes[i,18]

		@ nLin + 014,002  pSay aClientes[i,3]
		@ nLin + 014,010  pSay aClientes[i,4]
		@ nLin + 015,002  pSay aClientes[i,5]
		@ nLin + 015,045  pSay aClientes[i,6]
		@ nLin + 015,070  pSay aClientes[i,7]

		Eject

	Next

Elseif mv_par06 == 3  // Banco Real

	For i:=1 to Len(aClientes)

		@ nLin + 002,057  pSay aClientes[i,13]
		@ nLin + 005,010  pSay dDataBase
		@ nLin + 005,035  pSay aClientes[i,8]

		@ nLin + 007,062  pSay aClientes[i,9]
		@ nLin + 009,002  pSay mv_par07
		@ nLin + 010,002  pSay mv_par08
		@ nLin + 011,002  pSay mv_par09
		@ nLin + 012,002  pSay aClientes[i,17]
		@ nLin + 013,002  pSay aClientes[i,18]

		@ nLin + 014,002  pSay aClientes[i,3]
		@ nLin + 014,010  pSay aClientes[i,4]
		@ nLin + 015,002  pSay aClientes[i,5]
		@ nLin + 015,045  pSay aClientes[i,6]
		@ nLin + 015,070  pSay aClientes[i,7]

		Eject

	Next

Endif

SetPrc(0,0)        // (Zera o Formulario)
MS_FLUSH()

Set Print to
Set Device to Screen

If aReturn[5] == 1
     
   OurSpool( NomeRel )

EndIf

Return .T.           
