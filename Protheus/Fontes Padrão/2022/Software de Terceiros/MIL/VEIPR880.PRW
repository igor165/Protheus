#INCLUDE "veipr880.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEIPR880  º Autor ³ Andre              º Data ³  10/02/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Relatorio de Lances                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³VIP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VEIPR880

Local cTitulo       := STR0001 //"Reuniao"
Local nLin         := 80
Local Cabec1       := STR0002  //"              R e l a t o r i o       p a r a       R e u n i a o"
Local Cabec2       := STR0003 //"Cota Nome                  Veiculo             Codigo    Fone        Situacao"
Local aOrd := {}
Local cDesc1       := STR0004 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := STR0005 //"de acordo com os parametros informados pelo usuario."
Local cDesc3       := STR0001 //"Reuniao"
Local cPict        := ""
Local imprime      := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private Titulo       := STR0001 //"Reuniao"
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private limite     := 80
Private tamanho    := "P"
Private nomeprog   := "VEIPR880" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo      := 18
Private aReturn    := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey   := 0
Private cbtxt      := Space(20)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "REUNIAO" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString    := "VP1"
Private cPerg  := "VEI880"

dbSelectArea("VP1")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wNrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,nLin) },Titulo)
Return

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cGrupo

dbSelectArea(cString)
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

If !Empty(mv_par01) .or. !Empty(mv_par02)
   DbSeek(xFilial("VP1")+mv_par01)
Else
   DbSeek(xFilial("VP1"))
Endif

cGrupo := "NAOEX"

While !EOF() .and. VP1->VP1_FILIAL == xFilial("VP1")
   If !Empty(mv_par01) .or. !Empty(mv_par02)
      if VP1_CODGRU < MV_PAR01 .or. VP1_CODGRU > MV_PAR02
         Exit
      Endif   
   EndIf

   DbSelectArea("VP6")
   DbGotop()
   DbSeek(xFilial("VP6")+VP1->VP1_CODBEM)
  
   DbSelectArea("SA1")
   DbGotop()             
   DbSeek(xFilial("SA1")+VP1->VP1_CODCLI+VP1->VP1_LOJA)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If lAbortPrint
      @nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nLin >= 53
        
	   	nLin := 1
		nLin := cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) + 1      

	EndIf  

	If VP1->VP1_CODGRU # cGrupo
	                                   
   	 	@ nLin++ , 000 psay " " 	   
	   	@ nLin++, 000 psay STR0009 + VP1->VP1_CODGRU  //" - Grupo: "
	 	@ nLin++ , 000 psay " " 	   
	   	cGrupo := VP1->VP1_CODGRU 
	   
    EndIf
        
	If nLin >= 53
        
	   	nLin := 1
		nLin := cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) + 1      
	 	@ nLin++ 

	EndIf  

   @ nLin,000 psay VP1->VP1_NUMCOT
   @ nLin,005 psay substr(SA1->A1_NOME,1,20)
   @ nLin,027 psay substr(VP6->VP6_DESBEM,1,20)
   @ nLin,047 psay substr(VP6->VP6_CODBEM,1,8)
   @ nLin,057 psay substr(SA1->A1_TEL,1,12)
   If VP1->VP1_STATUS == "1"
      @ nLin,069 psay STR0010 //"NORMAL"
   ElseIf VP1->VP1_STATUS == "2"
      @ nLin,069 psay STR0011 //"CONTEMPLADA"
   ElseIf VP1->VP1_STATUS == "3"
      @ nLin,069 psay STR0012    //"CONGELADA"
   Else   
      @ nLin,069 psay STR0013 //"CANCELADA"
   EndIf   

    nLin := nLin + 1

	If nLin >= 53
        
	   	nLin := 1
		nLin := cabec(Titulo,cabec1,cabec2,nomeprog,tamanho,nTipo) + 1      
	 	@ nLin++ 

	EndIf  

	DbSelectArea("VP1")
   	dbSkip() // Avanca o ponteiro do registro no arquivo
EndDo

    nLin := nLin + 1 
    @ nLin++ , 00 psay Repl("=",80)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return