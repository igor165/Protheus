#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#include "PLSMGER.CH"
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSC016 � Autor � Angelo Sperandio     � Data � 11.04.2006 潮�
北媚哪哪哪哪呐哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Consulta historico de saldos do usuario                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/

Function PLSC016()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Inicializa variaveis                                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
LOCAL aCores 	  := {}
LOCAL lCent 	  := __SetCentury()
PRIVATE cPerg     := "PLC016"
PRIVATE cCadastro := ""
PRIVATE aRotina   := MenuDef()


aCores := 	{ 	{ "BA1->BA1_MOTBLO<>Space(03)", 'BR_VERMELHO' },;
				{ "BA1->BA1_MOTBLO==Space(03)", 'BR_VERDE' }}
					
aCdCores  	:= { 	{ 'BR_VERDE'    ,"Usuario ativo"},; 
					{ 'BR_VERMELHO' ,"Usuario Bloqueado"} } 
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ativa F12                                                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
SetKey(VK_F12,{||Pergunte(cPerg,.T.) })
 
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Ativa 4 digitos para o cadastro de usuarios...                           �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁                 
__SetCentury( "on" ) 
BA1->(dbSetOrder(1))
BA1->(MsSeek(xFilial("BA1")))
BA1->(mBrowse(006,001,022,075,'BA1',,,,,,aCores,,,,, .T. ))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Retorna ao modo original...                                            	 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁                 
SET KEY VK_F12 TO              
__SetCentury(If(lCent,"on","off"))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da funcao                                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Return()

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪穆哪哪哪穆哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪哪勘�
北砅rograma  � PLSC016MOV� Autor � Angelo Sperandio   � Data � 11.04.2006 潮�
北媚哪哪哪哪呐哪哪哪哪哪牧哪哪哪牧哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪哪幢�
北矰escri噭o � Consulta historico de saldos do usuario                    潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砋so       � Advanced Protheus                                          潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros� Nenhum                                                     潮�
北媚哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           潮�
北媚哪哪哪哪哪穆哪哪哪哪履哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅rogramador � Data   � BOPS �  Motivo da Altera噭o                     潮�
北媚哪哪哪哪哪呐哪哪哪哪拍哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北滥哪哪哪哪哪哪哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
                                                          
Function PLSC016MOV()

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Array com valores mes a mes                                              �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Posiicona no titular                                                     �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BA1->(dbSetOrder(2))
BA1->(msSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+GETMV("MV_PLCDTGP")))
cTitulo := "Consulta Historico de Saldos: " + alltrim(BA1->BA1_MATANT) + " - " + BA1->BA1_NOMUSR
BM1->(dbSetOrder(1))
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Solicita parametros                                                      �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
Pergunte(cPerg,.F.)
dDatRef := mv_par01
cCodDe  := mv_par02
cCodAte := mv_par03
cMes    := strzero(month(dDatRef),2)
cAno    := strzero(year(dDatRef),4)

If cAno < "1950"
	cAno := "1950"
Endif
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Executa um filtro no arquivo de credenciados...                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
While .T.
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //� Processa BM1-Composicao da Cobranca                                      �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   BM1->(msSeek(xFilial("BM1")+cCodInt+cCodEmp+cMatric+cAno+cMes))
   While ! BM1->(eof()) .and. BM1->(BM1_FILIAL+BM1_CODINT+BM1_CODEMP+BM1_MATRIC+BM1_ANO+BM1_MES) == ;
                               xFilial("BM1")+cCodInt+cCodEmp+cMatric+cAno+cMes
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Salta registros                                                          �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      If  BM1->BM1_CODTIP < cCodDe .or. ;
          BM1->BM1_CODTIP > cCodAte
          BM1->(dbSkip())
          Loop
      Endif
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Atualiza campos no array                                                 �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      nPos := aScan(aHisMes,{|x| x[1] == cAno .and. x[2] == cMes .and. x[3] == BM1->BM1_CODTIP})
      If  nPos == 0 
          cDesc := Posicione("BFQ",1,xFilial("BFQ")+cCodInt+BM1->BM1_CODTIP,"BFQ_DESCRI")
          aadd(aHisMes,{cAno,cMes,BM1->BM1_CODTIP,cDesc,0,0,0,0,0,0,""})
          nPos := len(aHisMes)
      Endif
      aHisMes[nPos, 7] += BM1->BM1_VALOR
      aHisMes[nPos, 8] += BM1->BM1_VALMES
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Acessa proximo registro                                                  �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      BM1->(dbSkip())
   Enddo
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //� Determina proximo mes/ano                                                �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   cMes := strzero(val(cMes)+1,2)
   If  cMes > "12"
       cMes := "01"
       cAno := strzero(val(cAno)+1,4)
   Endif
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //� Se mes/ano for maior que a data base, encerra a funcao                   �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   If  cAno+cMes > substr(dtos(dDataBase),1,6)
       Exit
   Endif
Enddo
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Busca saldos no BK2-Saldos do Usuario        					    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�

BK2->(dbSetOrder(5))
For nInd := 1 to len(aHisMes)
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //� Acessa saldo do mes no BK2-Saldos do Usuario                             �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   cAno    := aHisMes[nInd,1]
   cMes    := aHisMes[nInd,2]
   cCodLan := aHisMes[nInd,3]                                                 
   cChaveBK2 := xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan
   If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Atualiza campos no array                                                 �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN)
      	aHisMes[nInd, 9] += BK2->BK2_SALDO
      	aHisMes[nInd,10] += BK2->BK2_SALDO2
		   BK2->(DbSkip())
		Enddo
   Endif
   //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
   //� Acessa saldo do mes anterior no BK2-Saldos do Usuario                    �
   //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
   If  cMes == "01"
       cMes := "12"        
       cAno := alltrim(str(val(cAno)-1))
   Else
       cMes := strzero(val(cMes)-1,2)
   Endif                                                                
   cChaveBK2 := xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan
   If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Atualiza campos no array                                                 �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN)
      	aHisMes[nInd, 5] += BK2->BK2_SALDO
      	aHisMes[nInd, 6] += BK2->BK2_SALDO2                                                                                         
      	BK2->(DbSkip())
		Enddo
   Endif
Next   
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Exibe janela de consulta                     					    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
	If  Len(aHisMes) > 0
    //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    //� Identifica o saldo inicial                   					    �
    //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
    
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
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Fim da funcao                                					    �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
Return()

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma   砅LSC016SA  � Autor � Daher			         � Data � 03.02.05 潮�
北媚哪哪哪哪哪拍哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao  � 				                                                潮�
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
/*/

Function PLSC016SA
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
//� Declaracao de variaveis...                                          �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪�
LOCAL aSays     := {}
LOCAL cPerg     := 'PLC017'
LOCAL aButtons  := {}
LOCAL cCadastro := "Altera玢o do saldo devedor"

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta texto para janela de processamento                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
AADD(aSays,"Altera玢o do saldo devedor dos usu醨ios.")
AADD(aSays,"As altera珲es ser鉶 gravadas na base de dados para posterior auditoria.")
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Monta botoes para janela de processamento                                �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| MsAguarde({|| PLSC016SAPro(cPerg)}, "", "Processando...", .T.),FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| FechaBatch() }} )
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Exibe janela de processamento                                            �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
FormBatch( cCadastro, aSays, aButtons,, 250 )

//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Fim da Rotina Principal...                                               �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁

Return
/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma   砅LSC016SAPr� Autor � Daher			         � Data � 03.02.05 潮�
北媚哪哪哪哪哪拍哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao  � 				                                                潮�
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
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
	aadd(aCriticas,{"Para utiliza玢o desta rotina campo BK2_OBS (char,90) deve ser criado na base de dados."}) 
Endif       

If Empty(cObs)
	aadd(aCriticas,{"O preenchimento do campo de observa玢o � obrigat髍io."}) 
Else
	cObs += " ("+alltrim(Upper(PLRETOPE()))+")"
Endif
//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
//� Atualiza campos no array                                                 �
//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
BK2->(dbSetOrder(5))
If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Atualiza campos no array                                                 �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN) 

			nTotS1 += BK2->BK2_SALDO
      	nTotS2 += BK2->BK2_SALDO2
      	
      	BK2->(DbSkip())
		Enddo                       
		
		If (nSaldo1 > nTotS1 ) .and. nTipo == 2
		    aadd(aCriticas,{"O total do saldo 1 a ser abatido � maior que o saldo devedor do usu醨io."})
		Endif                
		
		If (nSaldo2 > nTotS2 ) .and. nTipo == 2
		    aadd(aCriticas,{"O total do saldo 2 A ser abatido � maior que o saldo devedor do usu醨io"})
		Endif
Else
	aadd(aCriticas,{"Nao foi possivel localizar saldo para o lancamento informado na respectiva compet阯cia."})
Endif


If  BK2->(msSeek(xFilial("BK2")+cCodInt+cCodEmp+cMatric+cAno+cMes+cCodLan))
      //谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      //� Atualiza campos no array                                                 �
      //滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
      While BK2->(!Eof()) .and. cChaveBK2 == BK2->(BK2_FILIAL+BK2_CODINT+BK2_CODEMP+BK2_MATRIC+BK2_ANO+BK2_MES+BK2_PROPRI+BK2_CODLAN) .and.;
      								   (nSaldo2 > 0 .or. nSaldo1 > 0) .and. Len(aCriticas) == 0
      	
      	BK2->(Reclock("BK2",.F.))
      		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      		//� Trata o saldo 1			                                                  �
      		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
      		//谀哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪目
      		//� Trata o saldo 2			                                                  �
      		//滥哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁
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
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪哪履哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪穆哪哪哪履哪哪哪哪目北
北砅rograma   砅LSC016LEG � Autor � Daher				      � Data � 03.02.05 潮�
北媚哪哪哪哪哪拍哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪牧哪哪哪聊哪哪哪哪拇北
北矰escricao  � 				                                                潮�
北滥哪哪哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
/*/
Function PLSC016LEG

BrwLegenda("Consulta hist醨ico de saldo","Status" ,aCdCores)
Return

/*/
苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘苘�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北砅rograma  矼enuDef   � Autor � Darcio R. Sporl       � Data �09/01/2007潮�
北媚哪哪哪哪呐哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噮o � Utilizacao de menu Funcional                               潮�
北�          �                                                            潮�
北�          �                                                            潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砇etorno   矨rray com opcoes da rotina.                                 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北砅arametros砅arametros do array a Rotina:                               潮�
北�          �1. Nome a aparecer no cabecalho                             潮�
北�          �2. Nome da Rotina associada                                 潮�
北�          �3. Reservado                                                潮�
北�          �4. Tipo de Transa噭o a ser efetuada:                        潮�
北�          �		1 - Pesquisa e Posiciona em um Banco de Dados           潮�
北�          �    2 - Simplesmente Mostra os Campos                       潮�
北�          �    3 - Inclui registros no Bancos de Dados                 潮�
北�          �    4 - Altera o registro corrente                          潮�
北�          �    5 - Remove o registro corrente do Banco de Dados        潮�
北�          �5. Nivel de acesso                                          潮�
北�          �6. Habilita Menu Funcional                                  潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪穆哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�   DATA   � Programador   矼anutencao efetuada                         潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北�          �               �                                            潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
Static Function MenuDef()
Private aRotina := {	{ STRPL01 	,'AxPesqui'  	, 0, K_Pesquisar 	, 0, .F.},;
			 			{ "Selecionar"	,'PLSC016MOV'	, 0, K_Visualizar	, 0, Nil},;
	                   	{ "Legenda"   	,"PLSC016LEG"	, 0, K_Incluir		, 0, .F.},;
	                   	{ "Manip.Saldo"	,"PLSC016SA"	, 0, K_Incluir		, 0, Nil} }
Return(aRotina)