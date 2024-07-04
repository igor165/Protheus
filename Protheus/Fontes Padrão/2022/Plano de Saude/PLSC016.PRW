#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#include "PLSMGER.CH"
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSC016 Ё Autor Ё Angelo Sperandio     Ё Data Ё 11.04.2006 Ё╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Consulta historico de saldos do usuario                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддддддддддддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Function PLSC016()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa variaveis                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL aCores 	  := {}
LOCAL lCent 	  := __SetCentury()
PRIVATE cPerg     := "PLC016"
PRIVATE cCadastro := ""
PRIVATE aRotina   := MenuDef()


aCores := 	{ 	{ "BA1->BA1_MOTBLO<>Space(03)", 'BR_VERMELHO' },;
				{ "BA1->BA1_MOTBLO==Space(03)", 'BR_VERDE' }}
					
aCdCores  	:= { 	{ 'BR_VERDE'    ,"Usuario ativo"},; 
					{ 'BR_VERMELHO' ,"Usuario Bloqueado"} } 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa F12                                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(VK_F12,{||Pergunte(cPerg,.T.) })
 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa 4 digitos para o cadastro de usuarios...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                 
__SetCentury( "on" ) 
BA1->(dbSetOrder(1))
BA1->(MsSeek(xFilial("BA1")))
BA1->(mBrowse(006,001,022,075,'BA1',,,,,,aCores,,,,, .T. ))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorna ao modo original...                                            	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                 
SET KEY VK_F12 TO              
__SetCentury(If(lCent,"on","off"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддддд©╠╠
╠╠ЁPrograma  Ё PLSC016MOVЁ Autor Ё Angelo Sperandio   Ё Data Ё 11.04.2006 Ё╠╠
╠╠цддддддддддедддддддддддадддддддаддддддддддддддддддддаддддддадддддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Consulta historico de saldos do usuario                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё Advanced Protheus                                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Nenhum                                                     Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL           Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддддддддддддддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
                                                          
Function PLSC016MOV()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Array com valores mes a mes                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local aHisMes := {}
Local nInd
Local nPos                                                              

Local nI
Local cMes
Local cAno
Local cDesc
Local cCodInt := BA1->BA1_CODINT
Local cCodEmp := BA1->BA1_CODEMP
Local cMatric := BA1->BA1_MATRIC   
Local cCodLan
Local cTitulo
Local cChaveBK2:= ""
Local aCabec := { {"Ano"              ,"@!", 20},;
                  {"Mes"              ,"@!", 20},;
                  {"Codigo"           ,"@!", 20},;
                  {"Descricao"        ,"@!",100},; 
                  {"Saldo Anterior 1"   ,"@E 999,999.99", 40},; 
                  {"Saldo Anterior 2" ,"@E 999,999.99", 40},; 
                  {"Vlr Desconto  Mes" ,"@E 999,999.99", 40},; 
                  {"Vlr Utilizado Mes","@E 999,999.99", 40},; 
                  {"Saldo Atual 1"    ,"@E 999,999.99", 40},; 
                  {"Saldo Atual 2"    ,"@E 999,999.99", 40},;
                  {""                 ,"@!"           ,  0} }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiicona no titular                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(dbSetOrder(2))
BA1->(msSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+GETMV("MV_PLCDTGP")))
cTitulo := "Consulta Historico de Saldos: " + alltrim(BA1->BA1_MATANT) + " - " + BA1->BA1_NOMUSR
BM1->(dbSetOrder(1))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Solicita parametros                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)
dDatRef := mv_par01
cCodDe  := mv_par02
cCodAte := mv_par03
cMes    := strzero(month(dDatRef),2)
cAno    := strzero(year(dDatRef),4)

If cAno < "1950"
	cAno := "1950"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa um filtro no arquivo de credenciados...                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .T.
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Processa BM1-Composicao da Cobranca                                      Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BM1->(msSeek(xFilial("BM1")+cCodInt+cCodEmp+cMatric+cAno+cMes))
   While ! BM1->(eof()) .and. BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES) == ;
                               xFilial("BM1")+cCodInt+cCodEmp+cMatric+cAno+cMes
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Salta registros                                                          Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If  BM1->BM1_CODTIP < cCodDe .or. ;
          BM1->BM1_CODTIP > cCodAte
          BM1->(dbSkip())
          Loop
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza campos no array                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nPos := aScan(aHisMes,{|x| x[1] == cAno .and. x[2] == cMes .and. x[3] == BM1->BM1_CODTIP})
      If  nPos == 0 
          cDesc := Posicione("BFQ",1,xFilial("BFQ")+cCodInt+BM1->BM1_CODTIP,"BFQ_DESCRI")
          aadd(aHisMes,{cAno,cMes,BM1->BM1_CODTIP,cDesc,0,0,0,0,0,0,""})
          nPos := len(aHisMes)
      Endif
      aHisMes[nPos, 7] += BM1->BM1_VALOR
      aHisMes[nPos, 8] += BM1->BM1_VALMES
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa proximo registro                                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BM1->(dbSkip())
   Enddo
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Determina proximo mes/ano                                                Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cMes := strzero(val(cMes)+1,2)
   If  cMes > "12"
       cMes := "01"
       cAno := strzero(val(cAno)+1,4)
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Se mes/ano for maior que a data base, encerra a funcao                   Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  cAno+cMes > substr(dtos(dDataBase),1,6)
       Exit
   Endif
Enddo
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca saldos no BK2-Saldos do Usuario        					    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

BK2->(dbSetOrder(5))
For nInd := 1 to len(aHisMes)
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acessa saldo do mes no BK2-Saldos do Usuario                             Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cAno    := aHisMes[nInd,1]
   cMes    := aHisMes[nInd,2]
   cCodLan := aHisMes[nInd,3]                                                 
   cChaveBK2 := xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan
   If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza campos no array                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN)
      	aHisMes[nInd, 9] += BK2->BK2_SALDO
      	aHisMes[nInd,10] += BK2->BK2_SALDO2
		   BK2->(DbSkip())
		Enddo
   Endif
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Acessa saldo do mes anterior no BK2-Saldos do Usuario                    Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If  cMes == "01"
       cMes := "12"        
       cAno := alltrim(str(val(cAno)-1))
   Else
       cMes := strzero(val(cMes)-1,2)
   Endif                                                                
   cChaveBK2 := xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan
   If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza campos no array                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN)
      	aHisMes[nInd, 5] += BK2->BK2_SALDO
      	aHisMes[nInd, 6] += BK2->BK2_SALDO2                                                                                         
      	BK2->(DbSkip())
		Enddo
   Endif
Next   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de consulta                     					    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If  Len(aHisMes) > 0
    //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Identifica o saldo inicial                   					    Ё
    //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    
	nSize := Len(aHisMes)
	While (nPos := aScan(aHisMes,{|x| x[5]+x[6]+x[7]+x[8]+x[9]+x[10] == 0})) != 0
			aDel(aHisMes,nPos)
			nSize--   
			aSize(aHisMes,nSize)
	Enddo
	aHisMes := aSort(aHisMes,,,{|x,y| x[1]+x[2] > y[1]+y[2]})
	PlsCriGen(aHisMes,aCabec,cTitulo,,,4,,,,,,,,,,,,,)
Else	
    msgstop("Usuario sem historico.")	
Endif
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da funcao                                					    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ЁPLSC016SA  Ё Autor Ё Daher			         Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё 				                                                Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/

Function PLSC016SA
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Declaracao de variaveis...                                          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL aSays     := {}
LOCAL cPerg     := 'PLC017'
LOCAL aButtons  := {}
LOCAL cCadastro := "AlteraГЦo do saldo devedor"

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta texto para janela de processamento                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aSays,"AlteraГЦo do saldo devedor dos usuАrios.")
AADD(aSays,"As alteraГУes serЦo gravadas na base de dados para posterior auditoria.")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta botoes para janela de processamento                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| MsAguarde({|| PLSC016SAPro(cPerg)}, "", "Processando...", .T.),FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe janela de processamento                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FormBatch( cCadastro, aSays, aButtons,, 250 )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ЁPLSC016SAPrЁ Autor Ё Daher			         Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё 				                                                Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Function PLSC016SAPro    
LOCAL cAno    := mv_par01
LOCAL cMes    := mv_par02
LOCAL nTipo   := mv_par03
LOCAL nSaldo1 := mv_par04
LOCAL nSaldo2 := mv_par05
LOCAL cCodLan := mv_par06
LOCAL cObs	  := alltrim(mv_par07)
LOCAL cCodInt := BA1->BA1_CODINT
LOCAL cCodEmp := BA1->BA1_CODEMP
LOCAL cMatric := BA1->BA1_MATRIC   
LOCAL cChaveBK2 := xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan
LOCAL nTotS1	 := 0
LOCAL nTotS2	 := 0
LOCAL aCriticas := {}

If BK2->(FieldPos("BK2_OBS")) == 0
	aadd(aCriticas,{"Para utilizaГЦo desta rotina campo BK2_OBS (char,90) deve ser criado na base de dados."}) 
Endif       

If Empty(cObs)
	aadd(aCriticas,{"O preenchimento do campo de observaГЦo И obrigatСrio."}) 
Else
	cObs += " ("+alltrim(Upper(PLRETOPE()))+")"
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza campos no array                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BK2->(dbSetOrder(5))
If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza campos no array                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN) 

			nTotS1 += BK2->BK2_SALDO
      	nTotS2 += BK2->BK2_SALDO2
      	
      	BK2->(DbSkip())
		Enddo                       
		
		If (nSaldo1 > nTotS1 ) .and. nTipo == 2
		    aadd(aCriticas,{"O total do saldo 1 a ser abatido И maior que o saldo devedor do usuАrio."})
		Endif                
		
		If (nSaldo2 > nTotS2 ) .and. nTipo == 2
		    aadd(aCriticas,{"O total do saldo 2 A ser abatido И maior que o saldo devedor do usuАrio"})
		Endif
Else
	aadd(aCriticas,{"Nao foi possivel localizar saldo para o lancamento informado na respectiva competЙncia."})
Endif


If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza campos no array                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN) .and.;
      								   (nSaldo2 > 0 .or. nSaldo1 > 0) .and. Len(aCriticas) == 0
      	
      	BK2->(Reclock("BK2",.F.))
      		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      		//Ё Trata o saldo 1			                                                  Ё
      		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      		If nTipo == 2
	      		If BK2->BK2_SALDO >= nSaldo1
	      			BK2->BK2_SALDO -= nSaldo1
	      			nSaldo1 := 0
	      		Else                        
	      			nSaldo1 -= BK2->BK2_SALDO
	      			BK2->BK2_SALDO := 0
	      		Endif
      		Else
      			BK2->BK2_SALDO += nSaldo1 
      			nSaldo1 := 0
      		Endif
      		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      		//Ё Trata o saldo 2			                                                  Ё
      		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      		If nTipo == 2
	      		If BK2->BK2_SALDO2 >= nSaldo2
	      			BK2->BK2_SALDO2 -= nSaldo2
	      			nSaldo2 := 0
	      		Else                        
	      			nSaldo2 -= BK2->BK2_SALDO2
	      			BK2->BK2_SALDO2 := 0
	      		Endif
	      	Else
      			BK2->BK2_SALDO2 += nSaldo2 
      			nSaldo2 := 0
	      	Endif	
      		BK2->BK2_OBS := cObs
      		
      	BK2->(MsUnlock())
      	
      	BK2->(DbSkip())
		Enddo
Endif    

If Len(aCriticas) > 0
	PLSCRIGEN(aCriticas,{ {"Critica","@C",260} }, "Nao foi possivel efetuar a alteracao do saldo.",NIL,NIL,NIL,NIL, NIL,NIL,"G",220)
Else
     MsgStop("Alteracao de saldo realizada com sucesso.")
Endif

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбдддддддддддбдддддддбддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   ЁPLSC016LEG Ё Autor Ё Daher				      Ё Data Ё 03.02.05 Ё╠╠
╠╠цдддддддддддедддддддддддадддддддаддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё 				                                                Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Function PLSC016LEG

BrwLegenda("Consulta histАrico de saldo","Status" ,aCdCores)
Return

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё09/01/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё		1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01 	,'AxPesqui'  	, 0, K_Pesquisar 	, 0, .F.},;
			 			{ "Selecionar"	,'PLSC016MOV'	, 0, K_Visualizar	, 0, Nil},;
	                   	{ "Legenda"   	,"PLSC016LEG"	, 0, K_Incluir		, 0, .F.},;
	                   	{ "Manip.Saldo"	,"PLSC016SA"	, 0, K_Incluir		, 0, Nil} }
Return(aRotina)