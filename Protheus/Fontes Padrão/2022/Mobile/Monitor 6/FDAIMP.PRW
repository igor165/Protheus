#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

// Pronta Entrega --------------------------------------------------------------------------------
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ImpNota   ³ Autor ³Marcelo Vieira         ³ Data ³ 21.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao Automatica de Nota Fiscal                          |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Numero do Pedido de Venda                                   ³±±
±±³          ³Serie da Nota Fiscal                                        ³±±
±±³          ³Numero do Embarque de Exportacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Numero do documento preparado                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Serie do Documento de Origem                         ³±±
±±³          ³ExpC2: Numero do Documento de Origem                        ³±±
±±³          ³ExpC3: Cliente/Fornecedor do documento do origem            ³±±
±±³          ³ExpC4: Loja do Documento de origem                          ³±±
±±³          ³ExpC5: Serie do Documento a ser gerado                      ³±±
±±³          ³ExpL6: Mostra Lct.Contabil                             (OPC)³±±
±±³          ³ExpL7: Aglutina Lct.Contabil                           (OPC)³±±
±±³          ³ExpL8: Contabiliza On-Line                             (OPC)³±±
±±³          ³ExpL9: Contabiliza Custo On-Line                       (OPC)³±±
±±³          ³ExpLA: Reajuste de preco na nota fiscal                (OPC)³±±
±±³          ³ExpNB: Tipo de Acrescimo Financeiro                    (OPC)³±±
±±³          ³ExpNC: Tipo de Arredondamento                          (OPC)³±±
±±³          ³ExpLD: Atualiza Amarracao Cliente x Produto            (OPC)³±±
±±³          ³ExplE: Cupom Fiscal                                    (OPC)³±±
±±³          ³ExpBF: CodeBlock de Selecao do SD2                     (OPC)³±±
±±³          ³       Parametros do codeblock                              ³±±
±±³          ³       ExpC1: Alias do arquivo SD2                          ³±±
±±³          ³       ExpC2: Alias do arquivo SF4                          ³±±
±±³          ³ExpBG: CodeBlock a ser executado para o SD2            (OPC)³±±
±±³          ³       Parametros do codeblock                              ³±±
±±³          ³       ExpN1:[1] Apos a copia do item do documento de saida ³±±
±±³          ³             [2] Apos a checagem da atualizacoes anteriores ³±±
±±³          ³       ExpA2:Array com o conteudo dos campos do SD2         ³±±
±±³          ³       ExpC3:Alias do SD2                              (OPC)³±±
±±³          ³       ExpC4:Alias do SF4                              (OPC)³±±
±±³          ³       ExpC5:Alias do SB1                              (OPC)³±±
±±³          ³ExpBH: CodeBlock a ser executado para o SF2            (OPC)³±±
±±³          ³       ExpN1:[1] Apos a copia do item do documento de saida ³±±
±±³          ³             [2] Apos a checagem da atualizacoes anteriores ³±±
±±³          ³ExpBI: CodeBlock a ser executado no final da transacao (OPC)³±±
±±³          ³ExpAJ: Array com os Recnos do SF2                      (OPC)³±±
±±³          ³       Deve possuir o mesmo tamanho da ExpAl           (OPC)³±±
±±³          ³ExpAL: Array com os itens do SD2                       (OPC)³±±
±±³          ³       [1] Item do SD2                                 (OPC)³±±
±±³          ³       [2] Conteudo dos campos na ordem da estrutura   (OPC)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Exemplo: MaNfs2Nfs(cSerOri,cNumORI,cClieFor,cLoja,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,bFilSD2,bSD2,bSF2,bTTS,aDocOri,aItemOri)
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
User Function ImpNota()
Local cSerOri:="",cNumORI:="",cClieFor:="",cLoja:="",cSerieNFS:=""
// Opcionais
//Local lMostraCtb:=.F.,lAglutCtb:=.F.,lCtbOnLine:=.F.,lCtbCusto:=.F.,lReajusta:=.F.
//Local nCalAcrs,nArredPrcLis,lAtuSA7,lECF,bFilSD2,bSD2,bSF2,bTTS
Local aArquivos:={}
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cFileCab   :="HF2" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileIte   :="HD2" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileCli    :="HA1" + cEmpAnt + "0" 
Local cItemNovo  :="00" 
Local cVend      := PALMUSER->P_CODVEND
Local cPrefixo   := GetNewPar( "MV_FDAPREF","RUA")

aAdd(aArquivos, {cFileCab, "HF2", "F2_DOC+F2_SERIE" })
aAdd(aArquivos, {cFileIte, "HD2", "D2_DOC+D2_SERIE+D2_ITEM" } )
aAdd(aArquivos, {cFileCli, "HA1", "A1_COD+A1_LOJA"})
ConOut("PALMJOB: Importando Notas para " + Trim(PALMUSER->P_USER))

If PChkFile(cPathPalm, aArquivos)
   
   dbSelectArea("HF2")
   dbSetOrder(1)
   While HF2->(!Eof())
	
	   cItemNovo:="00"   
	   cSerOri  :=HF2->F2_SERIE
	   cNumORI  :=HF2->F2_DOC 
	   cClieFor :=HF2->F2_CLIENTE
	   cLoja    :=HF2->F2_LOJA
	   cSerieNFS:=HF2->F2_SERIE
	
	   HA1->(dbSetOrder(1))
	   HA1->(dbSeek(cClieFor+cLoja))
	
	   IF HF2->F2_STATUS=="N" .And. AllTrim(HA1->A1_STATUS) <> "N"
	
	      Conout( "PALMJOB: Serie   :" + cSerOri )
	      Conout( "PALMJOB: Numero  :" + cNumOri )
	      Conout( "PALMJOB: Cliente :" + cClieFor )
	      Conout( "PALMJOB: Loja    :" + cLoja )
	      Conout( "PALMJOB: Serie NF:" + cSerieNFS )           
	      
	      dbSelectArea("SF2")
	      SF2->( dbSetOrder(1) )
	      IF SF2->( !DBSEEK( xFilial("SF2") +  cNumOri + cSerOri + cClieFor + cLoja   ) ) 

    	     Begin Transaction
	         RecLock("SF2",.T.)			
	         
	         SF2->F2_FILIAL  := xFilial("SF2")
	         SF2->F2_SERIE   := HF2->F2_SERIE
	         SF2->F2_DOC     := HF2->F2_DOC 
	         SF2->F2_EMISSAO := HF2->F2_EMISSAO
	         SF2->F2_CLIENTE := HF2->F2_CLIENTE
	         SF2->F2_LOJA    := HF2->F2_LOJA   
	         SF2->F2_VEND1   := cVend 
	         SF2->F2_EST     := HF2->F2_EST    
	         SF2->F2_COND    := HF2->F2_COND
	         SF2->F2_TIPO    := "N"
	         SF2->F2_DUPL    := HF2->F2_DUPL
	         SF2->F2_PREFIXO := HF2->F2_PREFIXO                          
	         SF2->F2_TIPOCLI := HF2->F2_TIPOCLI
	         SF2->F2_VALBRUT := HF2->F2_VALBRUT
	         SF2->F2_VALMERC := HF2->F2_VALMERC
	         SF2->F2_VALICM  := HF2->F2_VALICM
	         SF2->F2_BASEICM := HF2->F2_BASEICM
	                                       
			 SF2->( dbCommit() )
	         SF2->(MsUnlock())    
	         End Transaction   
	      
	      Endif
	   
	      //Monta Cabecalho 
		  //Busca os items monta os itens
	      dbSelectArea("HD2")
	      dbSetOrder(1)
		  If dbSeek( HF2->F2_DOC+HF2->F2_SERIE )
   		     Begin Transaction                   
   		     
		     While HD2->D2_DOC == HF2->F2_DOC
                   cItemNovo:=Soma1(cItemNovo,2)   		      
	               Conout( "PALMJOB: Itens da NF " + cNumOri )
	               Conout( "PALMJOB: Documento : " + HD2->D2_DOC )
	               Conout( "PALMJOB: Codigo    : " + HD2->D2_COD )
		     
	               dbSelectArea("SD2")
	               dbSetOrder(3)
 				 	              	               
				   If SD2->( !DBSEEK( xFilial("SD2") + cNumOri + cSerOri + cClieFor + cLoja + HD2->D2_COD + cItemNovo  ) ) 
   				    	    RecLock("SD2",.T.)			
		   	               	
		                    SD2->D2_FILIAL := xFilial("SD2")
							SD2->D2_DOC    := HD2->D2_DOC   
							SD2->D2_ITEM   := cItemNovo
							SD2->D2_COD    := HD2->D2_COD   
							SD2->D2_UM     := HD2->D2_UM    
							SD2->D2_QUANT  := HD2->D2_QUANT 
							SD2->D2_NUMSEQ := SF4->( ProxNum() )
							SD2->D2_PRCVEN := HD2->D2_PRUNIT 
							SD2->D2_TOTAL  := HD2->D2_TOTAL 
							SD2->D2_VALIPI := HD2->D2_VALIPI
							SD2->D2_VALICM := HD2->D2_VALICM
							SD2->D2_TES    := HD2->D2_TES 
							SD2->D2_CF     := HD2->D2_CF  
							SD2->D2_DESC   := HD2->D2_DESC
							SD2->D2_IPI    := HD2->D2_IPI
							SD2->D2_PICM   := HD2->D2_PICM 
							SD2->D2_CLIENTE:= HD2->D2_CLIENTE
							SD2->D2_LOJA   := HD2->D2_LOJA   
							SD2->D2_EMISSAO:= HD2->D2_EMISSAO
							SD2->D2_GRUPO  := HD2->D2_GRUPO                      
							SD2->D2_TP     := HD2->D2_TP     
							SD2->D2_SERIE  := HD2->D2_SERIE  
							SD2->D2_PRUNIT := HD2->D2_PRUNIT 
							SD2->D2_EST    := HD2->D2_EST    
							SD2->D2_DESCON := HD2->D2_DESCON 
							SD2->D2_TIPO   := HD2->D2_TIPO   
							SD2->D2_BRICMS := HD2->D2_BRICMS 
							SD2->D2_BASEICM:= HD2->D2_BASEICM
							SD2->D2_VALACRS:= HD2->D2_VALACRS
							SD2->D2_ICMSRET:= HD2->D2_ICMSRET
							SD2->D2_BASEIPI:= HD2->D2_BASEIPI
							SD2->D2_BASEISS:= HD2->D2_BASEISS
							SD2->D2_VALISS := HD2->D2_VALISS 
							SD2->D2_SEGURO := HD2->D2_SEGURO 
							SD2->D2_VALFRE := HD2->D2_VALFRE 
							SD2->D2_QTDEFAT:= HD2->D2_QTDEFAT   
							SD2->D2_TIPO   := "N"
		
							//Grava Local 
							IF SB1->( dbSeek( xFilial("SB1") + HD2->D2_COD ) )
							   SD2->D2_LOCAL := SB1->B1_LOCPAD     
							   SD2->D2_TP    := SB1->B1_TIPO
		                    ENDIF					           					
    		
						SD2->( dbCommit() )
						SD2->(MsUnlock())    
				   endif	
					
			   HD2->( dbSkip() )
			   
		     Enddo                  
   			End Transaction   	                                 
	      Endif
	   
	      dbSelectArea("HF2")
	      RecLock("HF2",.F.)			// Altera o FLag para Processada 
	      HF2->F2_STATUS := "P"
	      HF2->( MsUnlock() )
	   
	      ConOut( "ImpNota: Nota importada com sucesso : " + cNumOri ) 
	      
	      // Se Houverem titulos a Receber tambem importa 
    	  
	      FDA040(cClieFor,cLoja,cNumORI,cSerOri,cPrefixo)  
    	  
	      dbSelectArea("HF2")
	      
	   Endif
	   
	   HF2->(dbSkip())	  
	      
   EndDo	

   HF2->(dbCloseArea())	
   HD2->(dbCloseArea())	
   HA1->(dbCloseArea())
   
Else
	ConOut("PALMJOB: Arquivo de notas de saida nao encontrado.")
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FDA040    ³ Autor ³Marcelo Vieira         ³ Data ³ 21.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao Automatica de Titulos do caminhao                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function FDA040(cClieFor,cLoja,cNumero,cSerie,cPrefixo)

Local   _aTit := {}
Local   nK
Local   aArquivos :={}
Local   cPathPalm := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local   cFileHE1  :="HE1" + Left(PALMSERV->P_EMPFI,2) + "0"
Local   nx:=0
Local   _nRecBax  := {}                
Local   cFdaNatur := GetNewPar( "MV_FDANAT","FDA" )  
Local   cVend     := PALMUSER->P_CODVEND

Private lMsHelpAuto := .T. 
Private lMsErroAuto := .F. 
Private lc050Auto   := .T. // Indica que eh uma rotina automatica.
Public  ntotabat:=0

Criatipos()

aAdd(aArquivos, {cFileHE1, "HE1", "E1_CLIENTE+E1_LOJA+E1_NUM+E1_PARCELA" })

ConOut("PALMJOB: Importando Titulos para " + Trim(PALMUSER->P_USER))
 
_aTit := {}

If PChkFile(cPathPalm, aArquivos)
   
   dbSelectArea("HE1")
   dbSetOrder(1)     
   HE1->( dbSeek ( cClieFor+cLoja+cNumero ) )
     
   While HE1->( !Eof() ) .And. HE1->(E1_CLIENTE+E1_LOJA) == cClieFor+cLoja
   	  
	    If HE1->E1_STATUS =="N"  

		   //Inclusao de C.Receber
			
			AADD(_aTit , {"E1_NUM"    ,HE1->E1_NUM                     ,NIL})
			AADD(_aTit , {"E1_PREFIXO",cPrefixo                        ,NIL})
			AADD(_aTit , {"E1_SERIE"  ,cSerie                          ,NIL})
			AADD(_aTit , {"E1_PARCELA",HE1->E1_PARCELA                 ,NIL})
			AADD(_aTit , {"E1_TIPO"   ,HE1->E1_TIPO                    ,NIL})
            AADD(_aTit , {"E1_NATUREZ",cFdaNatur                       ,NIL})
			AADD(_aTit , {"E1_CLIENTE",HE1->E1_CLIENTE                 ,NIL})
			AADD(_aTit , {"E1_LOJA"   ,HE1->E1_LOJA                    ,NIL})
			AADD(_aTit , {"E1_EMISSAO",HE1->E1_EMISSAO                 ,NIL})
			AADD(_aTit , {"E1_VENCTO" ,HE1->E1_VENCTO                  ,NIL})
			AADD(_aTit , {"E1_VENCREA",DataValida(HE1->E1_VENCTO,.T.) ,NIL})
			AADD(_aTit , {"E1_VENCORI",DataValida(HE1->E1_VENCTO,.T.) ,NIL})
			AADD(_aTit , {"E1_VALOR"  ,HE1->E1_SALDO                   ,NIL})
			AADD(_aTit , {"E1_EMIS1"  ,Ddatabase                       ,NIL})
            AADD(_aTit , {"E1_VEND1"  ,cVend                           ,NIL})
                        
            // Guarda o Recno para marcar que o titulo foi baixado 
                     
            MSExecAuto({|x, y| FINA040(x, y)}, _aTit, 3)
	
            If  lMsErroAuto
	            MOSTRAERRO()
	            ConOut( "PALMJOB: Titulo(s) nao Incluido(s) !!! " )      
            else           
                HE1->( dbGoto( HE1->(Recno()) ) )                           
                RecLock("HE1",.F.)  // Altera o FLag para Processado 
                HE1->E1_STATUS :="P"
                HE1->( MsUnlock() )
                ConOut( "PALMJOB: Titulo(s) Incluido(s) com sucesso !!! " )      
            EndIf
            _aTit   := {}
               
		endif 
		 
		HE1->( dbSkip() )
		
   EndDo

Else
	ConOut("PALMJOB: Arquivo de Titulos a receber nao encontrado.")
EndIf

HE1->(dbCloseArea())	
   
Return 
   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FDA070    ³ Autor ³Marcelo Vieira         ³ Data ³ 21.11.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclusao Automatica de Titulos do caminhao                  |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/   
  
User Function FDA070()    
Local cBacoFDA := GetNewPar( "MV_FDABCO","FDA" ) 
Local cAgenFDA := GetNewPar( "MV_FDAAGE","FDA01" ) 
Local cContFDA := GetNewPar( "MV_FDACTA","FDA-0001" ) 
	
//Baixa Titulos a Receber

AADD(_aTit , {"E1_PREFIXO","001"                          ,NIL})
AADD(_aTit , {"E1_NUM"    ,"900012"                       ,NIL})
AADD(_aTit , {"E1_PARCELA","C"                            ,NIL})
AADD(_aTit , {"E1_TIPO"   ,"DP "                          ,NIL})
AADD(_aTit , {"E2_CLIENTE","F00001"                       ,NIL})
AADD(_aTit , {"E1_LOJA"   ,"01"                           ,NIL})
AADD(_aTit , {"AUTMOTBX"	 , "NORMAL"                   ,Nil})
AADD(_aTit , {"AUTBANCO"	 , cBacoFDA                   ,Nil})
AADD(_aTit , {"AUTAGENCIA"	 , cAgenFDA                   ,Nil})
AADD(_aTit , {"AUTCONTA"	 , cContFDA                   ,Nil})
AADD(_aTit , {"AUTDTBAIXA"	 , dDataBase                  ,Nil})
AADD(_aTit , {"AUTDTCREDITO" , dDataBase                  ,Nil})
AADD(_aTit , {"AUTHIST"	    , 'Baixa Automatica Pag'      ,Nil})
AADD(_aTit , {"AUTDESCONT"	 , 0                          ,Nil })
AADD(_aTit , {"AUTACRESC"	 , 0                          ,Nil })
AADD(_aTit , {"AUTDECRESC"	 , 0                          ,Nil })
AADD(_aTit , {"AUTMULTA"	 , 0                          ,Nil })
AADD(_aTit , {"AUTJUROS"	 , 0                          ,Nil })
AADD(_aTit , {"AUTVALREC"	 , 100                        ,Nil })
//Quando o titulo nao for em real
AADD(_aTit , {"AUTTXMOEDA"	 , 3	                      ,Nil })		
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a Baixa do Titulo                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MSExecAuto({|x, y| FINA070(x, y)}, _aTit, 3)

If  lMsErroAuto
	MOSTRAERRO() // Sempre que o micro comeca a apitar esta ocorrendo um erro desta forma
                 // deve ser liberado a funcao mostraerro para ajudar na analise
EndIf

/*/  
ConOut("****************************************")
ConOut("** Baixado ! **")
ConOut("****************************************")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PImpRecP ³ Autor ³ Marcelo Vieira        ³ Data ³ 13.10.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao dos Recebimentos do FDA                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PImpRecP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                             	                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PImpRecP                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PImpRecP()
Local aArquivos  := {}
Local cFileRec   :="HEL" + cEmpAnt + "0" 
Local nSeq       := 1
Local cPathPalm  := GetSrvProfString("HandHeldDir","\HANDHELD\") + "P" + AllTrim(PALMUSER->P_DIR) + "\atual\"
Local cVend      := AllTrim(PALMUSER->P_CODVEND)
Local lImpOK     :=.f.
Local aHelProc   := {}  // Guarda os recnos dos registros processados 
Local aPagtoEF   := {}  // Pagamentos em dinheiro 
Local aPagtosCH  := {}  // Pagamentos em Cheques
Local nPos       := 0

aAdd(aArquivos, { cFileRec, "HEL","EL_STATUS+EL_CLIENTE+EL_LOJA+EL_SEQ"} )

ConOut("PALMJOB: Importando Recebimento do FDA para " + Trim(PALMUSER->P_USER))

If PChkFile(cPathPalm, aArquivos)
	dbSelectArea("HEL")                                                   
	dbSetOrder(1)
	dbSeek( "N" ) //posiciona os registros cujo status e "N"  de novo 
	While HEL->( !Eof() ) .And. HEL->EL_STATUS="N" 

          If HEL->EL_TIPODOC="EF"   // Aglutina pagamentos em dinheiro 
      		 nPos := Ascan(aPagtoEF, { |X| X[1] = HEL->EL_CLIENTE + HEL->EL_LOJA })	    
	         If nPos<>0 
	            aPagtoEF[nPOs,3] := aPagtoEF[nPOs,3] + HEL->EL_VALOR
	            //Adiciona o recno para depois gravar flag de processado
	            Aadd( aHelProc, HEL->(Recno()) )
	         else
	            Aadd( aPagtoEF, { HEL->EL_CLIENTE + HEL->EL_LOJA, HEL->EL_TIPODOC, HEL->EL_VALOR } )
	            //Adiciona o recno para depois gravar flag de processado
	            Aadd( aHelProc, HEL->(Recno()) )
	         endif            
	         
	      Elseif HEL->EL_TIPODOC="CH"   // Aglutina pagamentos em Cheques

      		 nPos := Ascan(aPagtosCH, { |X| X[1] = HEL->EL_CLIENTE + HEL->EL_LOJA + HEL->EL_SEQ })	    
	         If nPos=0 
	            Aadd( aPagtosCH, { HEL->EL_CLIENTE + HEL->EL_LOJA, HEL->EL_TIPODOC, HEL->EL_VALOR, HEL->(RECNO()) } )
	            //Adiciona o recno para depois gravar flag de processado
	            Aadd( aHelProc, HEL->(Recno()) ) 
	         endif            	      
	      
	      endif                 
	      HEL->( dbSkip() )
  	EndDo		
  	// Faz a baixa dos titulos se existirem baixas
    if Len(aPagtoEF)>0 .Or. Len(aPagtosCH)>0 .Or. Len(aHelProc)>0
       PImpRec01(aPagtoEF,aPagtosCH,aHelProc)
    endif
    HEL->(dbCloseArea())	
    
Else
	ConOut("PALMJOB: Arquivo de Recebimentos  nao encontrado.")

EndIf

Return

/*
Busca os titulos dos clientes para baixar  
*/
Static Function PImpRec01(aPagtoEF,aPagtosCH,aHelProc)
Local  aTitBxDin :={} 
Local  aTitBxChq :={} 
Local  nDinheiro:=Len(aPagtoEF) 
Local  nCheques :=Len(aPagtosCH)
Local  lBaixaOk :=.f.
Local  nDin:=1, nChq:=1 
Local  cCliLoj  :=""                    
Local  nTotDin  :=0
Local  nTotChq  :=0         
Local  nTotalSE1:=0
Local  nSelSE1Chq:=0
Local  aBaixa   :={}
Local  cMotBxProc:="NOR"
Local  cBancoFda:=GetMV("MV_FDABCO",,"FDA")
Local  CContaFda:=GetMV("MV_FDACTA",,"FDA-0001")
Local  CAgencFda:=GetMV("MV_FDAAGE",,"FDA01")
Local  dBaixaProc,dDtCredProc
Local  nRecProc,nProc
Local  aParam:={}
Local  aLiq  :={} 

//Data da Baixa
dBaixaProc :=Date()
dDtCredProc:=Date() 
//Compatibiliza as variaveis com tamanho dos campos                                      
CContaFda:=Pad(CContaFda, TamSx3("E8_CONTA")[1])
CAgencFda:=Pad(CAgencFda, TamSx3("E8_AGENCIA")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona parametros para a funcao de baixa baseado na pergunta do F12³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("OMS341",.F.)
Aadd(aParam,(mv_par01 == 1))
Aadd(aParam,(mv_par02 == 1))
Aadd(aParam,(mv_par03 == 1))
Aadd(aParam,(mv_par04 == 1))
Aadd(aParam,(mv_par05 == 1))
Aadd(aParam,(mv_par06 == 1))

// 1o Faz a baixa por dinheiro
For nDin:=1 to nDinheiro
    cCliloj:=aPagtoEF[nDin,1]      // Obtem o cliente e loja para baixar
    nTotDin:=aPagtoEF[nDin,3]      // Obtem o total para pagar 
    dbSelectArea("SE1") 
    dbSetOrder(2)
    dbSeek( xFilial("SE1") + cCliloj )   
    If SE1->( found())    
       Do While SE1->(!EOF()) 
          if SE1->E1_CLIENTE+SE1->E1_LOJA <> cCliLoj 
             SE1->(dbSkip()) 
             Loop
          endif
          if SE1->E1_SALDO <> 0 
             aadd( aTitBxDin, SE1->(RECNO()) )
             nTotalSE1:=nTotalSE1 + SE1->E1_SALDO
             // Se ja atingiu o limite do valor de baixa passa para o Proximo cliente 
             if nTotalSe1 >=nTotDin         
                Exit 
             endif            
          endif  
          SE1->(dbSkip()) 
       Enddo 
       // Faz as Baixas com dinheiro  
       if Len(aTitBxDin) > 0 
          aBaixa   :={cMotBxProc,nTotDin,cBancoFda,cAgencFda,Pad(cContaFda,10),dBaixaProc,dDtCredProc}			
          MaintBxCr(1,aTitBxDin,aBaixa,nil,nil,aParam)
          lBaixaOk:=.t.
       endif              
    endif
Next

// 2o Faz a baixa por Cheques 
For nChq:=1 to nCheques        
    // Faz as Baixas com Cheques
    cCliloj:=aPagtosCH[nChq,1]     // Obtem o cliente e loja para baixar
    nTotChq:=aPagtosCH[nChq,3]     // Obtem o total para pagar 
    dbSelectArea("SE1") 
    dbSetOrder(2)
    dbSeek( xFilial("SE1") + cCliloj )   
    If SE1->( found())    
       Do While SE1->(!EOF()) 
          if SE1->E1_CLIENTE+SE1->E1_LOJA <> cCliLoj 
             SE1->(dbSkip()) 
             Loop
          endif
          if SE1->E1_SALDO <> 0 
             aadd( aTitBxChq, SE1->(RECNO()) )
             nSelSE1Chq := nSelSE1Chq + SE1->E1_SALDO
             // Se ja atingiu o limite do valor de baixa passa para o Proximo cliente 
             if nSelSE1Chq >= nTotChq
                Exit 
             endif            
          endif  
          SE1->(dbSkip()) 
       Enddo 
	   if Len(aTitBxChq) > 0 
	      // Obtem os dados do cheque para a baixa                
	      dbSelectArea("HEL") 	 
          HEL->( dbGoto( aPagtosCH[nChq,4] ) )
	      cPrefixo:= HEL->EL_PREFIXO
	      cBcoChq := HEL->EL_BCOCHQ
	      cAgeChq := HEL->EL_AGECHQ
	      cCtaChq := HEL->EL_CTACHQ
	      cNumChq := HEL->EL_NUMERO
	      dDatChq := HEL->EL_EMISSAO
	      nValChq := HEL->EL_VALOR
	      cTipChq := "CH "
	      dDataBs := HEL->EL_EMISSAO
	      aLiq    :={{cPrefixo,cBcoChq,cAgeChq,cCtaChq,cNumChq,dDatChq,nValChq,cTipChq,"",1,dDataBs }} 
	      MaIntBxCR(2,aTitBxChq,Nil,Nil,aLiq,aParam,Nil)				
	      lBaixaOk:=.t.
	   endif
  endif
Next

//Depois de tudo baixado, Marca Flag "P" de processado os titulos recebidos                          
if lBaixaOk
	dbSelectArea("HEL") 
	nRecProc:=Len(aHelProc)
	if nRecProc >0
	   For nProc:=1 to nRecProc
	       HEL->( dbGoto( aHelProc[nProc] ) )               
	       RecLock("HEL",.F.)			// Altera o FLag para Processada 
	       HEL->EL_STATUS := "P"
		   HEL->( MsUnlock() )
	   Next 
	endif
endif

Return 
