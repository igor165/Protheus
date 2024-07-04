#INCLUDE "PROTHEUS.CH"
#INCLUDE "RHLIBPER.CH"

/*/
������������������������������������������������������������������������Ŀ
�Fun��o    �InRhLibPerExec�Autor �Mauricio MR		   � Data �26/11/2007�
������������������������������������������������������������������������Ĵ
�Descri��o �Executar Funcoes Dentro de RHLIBPER                          �
������������������������������������������������������������������������Ĵ
�Sintaxe   �InRhLibPerExec( cExecIn , aFormParam )						 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �uRet                                                 	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �Generico 													 �
��������������������������������������������������������������������������/*/
Function InRhLibPerExec( cExecIn , aFormParam )
         
Local uRet

DEFAULT cExecIn		:= ""
DEFAULT aFormParam	:= {}

IF !Empty( cExecIn )
	cExecIn	:= BldcExecInFun( cExecIn , aFormParam )
	uRet	:= __ExecMacro( cExecIn )
EndIF

Return( uRet )



/**********************************/
//  E  X  E  M  P  L  O             //
/**********************************/

/*/   
�����������������������������������������������������������������������Ŀ
�Fun��o    �fGetPeriodo   � Autor � Equipe Advanced RH� Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Obtem o periodo de apontamento							    �
�����������������������������������������������������������������������Ĵ
�Exemplo   �oPeriodo:=RHPERIODO:New()       //Criacao do Obj            �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �fGetPeriodo(cFil,cMat,dDtPesq,dIniAfas,dFimAfas,cTipAfas)   �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������
Static Function fGetPeriodo( oPeriodo)

Local aArea 		:= GetArea()
Local lRet 			:= .T.

Begin Sequence      
   
	�������������������������������������������������������������Ŀ
	�Obtem Informacoes do Periodo Solicitado					  �
	���������������������������������������������������������������
	oPeriodo:GetPer()

    
	�������������������������������������������������������������Ŀ
	�Mostra Advertencia para Periodo Nao Encontrado				  �
	���������������������������������������������������������������
	If !oPeriodo:lFound
 		lRet		:= .F. 
		MsgInfo( OemToAnsi( oPeriodo:cMsgNotFoundPer ) )	//"Per�odo de Apontamento N�o Encontrado."
 		Break
	Endif

	�������������������������������������������������������������Ŀ
	�Mostra Advertencia de Periodo Aberto para Manutencao de Perio�
	�dos Fechados.												  �
	���������������������������������������������������������������
 	If oPeriodo:lAberto .and. lPona180
		MsgInfo( OemToAnsi( oPeriodo:cMsgOpenedPer ) )    //"Per�odo de Apontamento Aberto. Selecione ou informe um Per�odo Fechado."
 		lRet		:= .F.
 		Break

	�������������������������������������������������������������Ŀ
	�Mostra Advertencia de Periodo Fechado p/ Manutencao de Perio �
	�dos Abertos.												  �
	���������������������������������������������������������������
	//Se lpona180 for .f., somente podera ser visualizado periodos que estejam abertos (rch_dtfech vazio) 		
 	ElseIf oPeriodo:lFechado .and. !lPona180
		MsgInfo( OemToAnsi( oPeriodo:cMsgClosedPer ) )    //"Per�odo de Apontamento Fechado. Selecione ou informe um Per�odo Aberto."
		lRet		:= .F.
 		Break
 	EndIf

End Sequence


�������������������������������������������������������������Ŀ
�Recupera Valores do Periodo antes da Troca de Periodo 		  �
���������������������������������������������������������������
If !lRet
	oPeriodo:RollBack()
Endif

RestArea( aArea )

Return( lRet )
/*/


/*/
�����������������������������������������������������������������������Ŀ
�Classe    �RHPeriodo     � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Classe para a criacao do Objeto Periodo						�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= RHPeriodo():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������
�����������������������������������������������������������������������Ĵ
�		ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL				�
�����������������������������������������������������������������������Ĵ
�Programador� Data     � BOPS      | Motivo da Alteracao                �
�����������������������������������������������������������������������Ĵ
�IgorFranzoi�10/10/2008� BOPS      | Passagem por Ref. para PerAponta	�
�����������������������������������������������������������������������Ĵ
/*/

class RHPeriodo  
    data oPerAponta
	data cFilRCH
	data cProcesso
	data cRoteiro
    data cPeriodo
    data cNumPagto
    data cAno
    data cMes  
	data dDataIni
	data dDataFim
	data dDtFecha
	data lPerSel
	data lFechado
	data lAberto 
	data lFound	
	data lPGenerico 
	data lPerAponta
	data nRecno    
	data aPeriodos

	data cAntFilRCH
	data cAntProcesso
	data cAntRoteiro
  	data cAntPeriodo
    data cAntNumPagto
    data cAntAno
    data cAntMes  
	data dAntDataIni
	data dAntDataFim
	data dAntDtFecha	
	data lAntFechado
	data lAntAberto 
	data lAntFound	
	data nAntRecno
    
    data cMsgNotFoundPer
	data cMsgOpenedPer
	data cMsgClosedPer
	data cMsgPerAntOpened
	data cMsgPerNextClosed
	data cMsgPerNextNotFound
	
	method New() constructor    
	method AaDDPer(aItensPer,nPos)
	method GetPer(cFiltro)
	method PriAberto(cFiltro)	
	method PerAberto(cFiltro)  
	method PerSel(cFiltro) 
	method PerAnt(cFiltro)
	method PerUltFech(cFiltro)	
	method PerLoad()
	method RollBack() 
	 
endclass  


/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �New           � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para instanciar o objeto Periodo						�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= RHPeriodo():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method New() class RHPeriodo
	::cFilRCH		:= xFilial("RCH")
	::cProcesso		:= ""
	::cRoteiro      := "PON"
    ::cPeriodo		:= ""
    ::cNumPagto		:= ""
    ::cAno			:= ""
    ::cMes			:= ""
    ::dDataIni		:= Ctod("")
	::dDataFim		:= Ctod("")
	::dDtFecha		:= Ctod("")	
	::lPerSel		:= .F.
	::lFechado		:= .F.
	::lAberto		:= .F.		
	::lFound		:= .F.
	::lPGenerico	:= .F.
	::lPerAponta	:= .F.
	::nRecno		:= 0			
	
	::cAntFilRCH	:= ""
	::cAntProcesso	:= ""
	::cAntRoteiro   := "PON"
	::cAntPeriodo	:= ""
    ::cAntNumPagto	:= ""
    ::cAntAno		:= ""
    ::cAntMes		:= ""
    ::dAntDataIni	:= Ctod("")
	::dAntDataFim	:= Ctod("")
	::dAntDtFecha	:= Ctod("")		
	::lAntFechado	:= .F.
	::lAntAberto	:= .F.		
	::lAntFound		:= .F.
	::nAntRecno     := 0  
	
	::cMsgNotFoundPer	   := STR0001  //"Per�odo de Apontamento N�o Encontrado."
	::cMsgOpenedPer		   := STR0002  //"Per�odo de Apontamento Aberto. Selecione ou informe um Per�odo Fechado."
	::cMsgClosedPer		   := STR0003  //"Per�odo de Apontamento Fechado. Selecione ou informe um Per�odo Aberto."  
	::cMsgPerAntOpened     := STR0004  //"Per�odo de Apontamento anterior n�o foi fechado."
	::cMsgPerNextClosed    := STR0005  //"Pr�ximo Per�odo de Apontamento est� fechado."
	::cMsgPerNextNotFound  := STR0006  //"Pr�ximo Per�odo de Apontamento n�o foi encontrado. Cadastre-o para continuar."
    
    ::aPeriodos 	:= {}                    
    
    ::oPerAponta	:= PeriodoAp():New()		   	
Return(Nil)	

/*/
������������������������������������������������������������������������Ŀ
�Class     �PeriodoAp   � Autor �Mauricio MR		   � Data �02/07/2008�
������������������������������������������������������������������������Ĵ
�Descri��o �Classe com parametros da funcao PerAponta()					 �
������������������������������������������������������������������������Ĵ
�Sintaxe   �oObj := PeriodoAp():New()									 �
������������������������������������������������������������������������Ĵ
�Parametros�<Vide Parametros Formais>									 �
������������������������������������������������������������������������Ĵ
�Retorno   �self                                                   	     �
������������������������������������������������������������������������Ĵ
�Observa��o�                                                      	     �
������������������������������������������������������������������������Ĵ
�Uso       �class RHPERIODO                                              �
��������������������������������������������������������������������������/*/
class PeriodoAp
      
	data dDataIni			//Data Inicial passada como referencia
	data dDataFim 			//Data Final   passada como referencia
	data dData				//Data Base
	data lShowHelp			//Mostrar o Help
	data cFilMv				//Filial para GetMv
	data lNewPer			//Se eh para gerar um novo periodo
	data lPerCompleto		//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
	data lIncDate			//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
	data lUseParamPer		//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro
    
	method New() constructor    
endclass


/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �New           � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para instanciar o objeto Periodo						�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj	:= RHPeriodo():New() 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 	
Method New() class PeriodoAp
	::dDataIni		:=	Ctod('')	//Data Inicial passada como referencia
	::dDataFim 		:=	Ctod('')	//Data Final   passada como referencia
	::dData			:=	dDataBase	//Data Base
	::lShowHelp		:=	.T.			//Mostrar o Help
	::cFilMv		:=	cFilAnt		//Filial para GetMv
	::lNewPer		:=	.F.			//Se eh para gerar um novo periodo
	::lPerCompleto	:=	.F.			//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
	::lIncDate		:=	.T.			//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
	::lUseParamPer	:=	.F.			//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro
Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �AaDDPer       � Autor � Mauricio MR       � Data �25/06/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para adicionar periodos 								�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:AaDDPer(aItensPer,nPos) 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�����������������������������������������������������������������������Ĵ
�ATENCAO   �Verificar a possibilidade de alimentar recursivamente os    �
�          �atributos do oPeriodo atraves desse metodo.                 �
�������������������������������������������������������������������������/*/	
Method aADDPer(aItensPer,nPos) class RHPeriodo
Local nX
Local nPer

DEFAULT aItensPer		:= {;
    							{	 ::cFilRCH		,; //01
    								 ::cProcesso	,; //02
    								 ::cPeriodo		,; //03
    								 ::cRoteiro		,; //04
    								 ::cNumPagto	,; //05
    								 ::dDataIni		,; //06
    								 ::dDataFim		,; //07
    								 ::dDtFecha		,; //08
    								 ::cAno			,; //09
    								 ::cMes  		;  //10
    							};
   							}

nPer	:= Len(aItensPer)

For nX:=1 to nPer
    If ( nPos := Ascan(::aPeriodos,{|X|;
    						( X[1] + X[2] + X[3] + X[4] + X[5] ) ==;
    						( aItensPer[nX,1]+ aItensPer[nX,2] + aItensPer[nX,3] + aItensPer[nX,4] + aItensPer[nX,5] )	;
    					   };
    		  );
     	) == 0    
 	  	AADD(::aPeriodos, aItensPer[nX] )
 	  	nPos := Len(::aPeriodos)
 	Endif  	
Next

Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �GetPer        � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para obter o QUALQUER Periodo de Apontamento			�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:GetPer(cFiltro)		 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 
Method GetPer(cFiltro,lSemEspaco) class RHPeriodo
Local cKey      

DEFAULT cFiltro		:= "Eval({||.T.})"
DEFAULT	lSemEspaco	:= .T.
                                                   
cKey:= ::cProcesso + ::cRoteiro + ::cPeriodo + ::cNumPagto
cKey:= If(lSemEspaco, ::cFilRCH + Alltrim(cKey), cKey)
    
//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))        
fPosAlias("RCH", 4, cKey, cFiltro)    

::PerLoad()

Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PriAberto     � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para obter o Periodo de Apontamento ABERTO			�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PriAberto(cFiltro)		 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/	
Method PriAberto(cFiltro) class RHPeriodo
         
    DEFAULT cFiltro		:= "Eval({||.T.})"

    //05 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+DTOS(RCH_DTFECH)+RCH_PER+RCH_NUMPAG" )))    
	fPosAlias("RCH", 5, ::cFilRCH + ::cProcesso + ::cRoteiro + "", cFiltro)    
	
    ::PerLoad()
Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PerAberto     � Autor � Leandro Drumond   � Data �27/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para obter o Periodo de Apontamento ABERTO			�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PerAberto(cFiltro)		 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/	
Method PerAberto(cFiltro) class RHPeriodo
         
    DEFAULT cFiltro		:= "Eval({||.T.})"

	//02 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
	fPosAlias("RCH", 2, ::cFilRCH + ::cProcesso + ::cPeriodo + Space(8) + ::cRoteiro, cFiltro)    
	
    ::PerLoad()
Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PerUltFech    � Autor � Mauricio MR		  � Data �04/12/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para obter o Ultimo Periodo de Apontamento FECHADO	�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PerUltFech(cFiltro)		 							�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/ 

Method PerUltFech(cFiltro) class RHPeriodo

Private nLastRec	:= 0
         
DEFAULT cFiltro		:= "Eval({||fbPerUltFech(cKey)})"

	//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))  
	fPosAlias("RCH", 4, ::cFilRCH + ::cProcesso + ::cRoteiro, cFiltro,Nil)    	
    
    ::PerLoad()
Return(Nil)         

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PerSel        � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para obter o Periodo de Apontamento SELECIONADO		�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PerSel(cFiltro)	 	 								�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/	
Method PerSel(cFiltro) class RHPeriodo
        
     DEFAULT cFiltro		:= "Eval({||.T.})"
    
    //08 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL" )))    
	fPosAlias("RCH", 8, ::cFilRCH + ::cProcesso + ::cRoteiro + "1", cFiltro)
	 
    ::PerLoad()
Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PerAnt        � Autor � Igor Franzoi      � Data �28/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para retornar o Periodo Anterior ao periodo aberto   �
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PerAnt()  		   								    	�
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/
Method PerAnt(cFiltro) class RHPeriodo

	DEFAULT cFiltro := "Eval({|| .T. })"

    //09 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_DTINI" )))    
	fPosAlias("RCH", 9, ::cFilRCH + ::cProcesso + ::cRoteiro + Dtos(::dDataIni), cFiltro)
	
	::PerLoad()
	
Return (Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �PerLoad       � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo p/ Carregar as informacoes do Periodo de Apontamento �
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:PerLoad()	   								            �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/
Method PerLoad() class RHPeriodo
    
        
	::cAntFilRCH	:= ::cFilRCH
	::cAntPeriodo	:= ::cPeriodo
	::cAntNumPagto	:= ::cNumPagto	
	
	::dAntDataIni	:= ::dDataIni
	::dAntDataFim	:= ::dDataFim 
	::dAntDtFecha	:= ::dDtFecha 	
	
	::cAntAno		:= ::cAno
	::cAntMes		:= ::cMes
		
	::lAntFechado	:= ::lFechado
	::lAntAberto	:= ::lAberto
	::lAntFound		:= ::lFound
	::nAntRecno		:= ::nRecno  

	::cFilRCH	:= RCH->RCH_FILIAL
	::cPeriodo	:= RCH->RCH_PER
	::cNumPagto	:= RCH->RCH_NUMPAG	
	
	::dDataIni	:= RCH->RCH_DTINI
	::dDataFim	:= RCH->RCH_DTFIM 
	::dDtFecha	:= RCH->RCH_DTFECH
	
	::cAno		:= RCH->RCH_ANO
	::cMes		:= RCH->RCH_MES
	
	::lPerSel	:= If( (RCH->RCH_PERSEL == "1"), .T., .F. )
		
	::lFechado	:= !Empty(::dDtFecha)
	::lAberto	:= Empty(::dDtFecha)
	
	::lFound		:= !RCH->(Eof()) 
	
	::nRecno	:= IF(::lFound, RCH->(Recno()), 0)
	
	/*/
	�������������������������������������������������������������Ŀ
	�Verifica se Usa SIGAPON com Cadastro de Periodos			  �
	���������������������������������������������������������������/*/
	
	If ( ::lPGenerico	:= ( !( ::lFound ) .and. Empty( ::cPeriodo ) .and. Empty( ::cNumPagto ) ) ) 
		/*/
		�������������������������������������������������������������Ŀ
		�Alimenta os atributos do objeto com as informacoes do periodo�
		�de apontamento												  �
		���������������������������������������������������������������/*/  
		If !Empty(::lPerAponta)
			(::lFound:= GetPonMesDat( @::dDataIni , @::dDataFim , xFilial('SRA') ) )
		Else
			::oPerAponta:dDataIni:= IF( Empty(::oPerAponta:dDataIni),::dDataIni,::oPerAponta:dDataIni )	//Data Inicial passada como referencia
			::oPerAponta:dDataFim:= IF( Empty(::oPerAponta:dDataFim),::dDataFim,::oPerAponta:dDataFim ) 	//Data Final   passada como referencia 
			
			::lFound:= PerAponta(		@::oPerAponta:dDataIni		,;	//Data Inicial passada como referencia
										@::oPerAponta:dDataFim 		,;	//Data Final   passada como referencia
										@::oPerAponta:dData		 	,;	//Data Base
										@::oPerAponta:lShowHelp	  	,;	//Mostrar o Help
										@::oPerAponta:cFilMv		,;	//Filial para GetMv
										@::oPerAponta:lNewPer	 	,;	//Se eh para gerar um novo periodo
										@::oPerAponta:lPerCompleto	,;	//Se o periodo esta preenchido com AAAAMMDD/AAAAMMDD ou AAAAMMDDAAAAMMDD (por referencia)
										@::oPerAponta:lIncDate		,;	//Se Quando lNewPer Incrementa Data, caso contrario Decrementa
										@::oPerAponta:lUseParamPer	;	//Se quando periodo completo considerar dPerIni e dPerFim passados como parametro								 
								 ) 
								 
			::dDataIni	:=::oPerAponta:dDataIni						
			::dDataFim  :=::oPerAponta:dDataFim 						 
		Endif
	
		::cFilRCH		:= xFilial("RCH", SRA->RA_FILIAL)
		::cRoteiro      := "PON"
	    ::cPeriodo		:= ""
	    ::cNumPagto		:= ""

	    ::cAno			:= ""
	    ::cMes			:= ""

		::lFechado		:= .F.
		::lAberto		:= .F.		

		::nRecno		:= 0				
			
	Else
		/*
		::cFilRCH	:= RCH->RCH_FILIAL
		::cPeriodo	:= RCH->RCH_PER
		::cNumPagto	:= RCH->RCH_NUMPAG	
		
		::dDataIni	:= RCH->RCH_DTINI
		::dDataFim	:= RCH->RCH_DTFIM 
		::dDtFecha	:= RCH->RCH_DTFECH
		
		::cAno		:= RCH->RCH_ANO
		::cMes		:= RCH->RCH_MES
			                                            
			
			
			
		::lFechado	:= !Empty(::dDtFecha)
		::lAberto	:= Empty(::dDtFecha)
	
		::nRecno	:= IF(::lFound, RCH->(Recno()), 0)
        */
	Endif      
	
	::aADDPer()	
Return(Nil)	

/*/
�����������������������������������������������������������������������Ŀ
�Metodo    �RollBack      � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Metodo para retornar ao ultimo Periodo de Apontamento VALIDO�
�����������������������������������������������������������������������Ĵ
�Par�metros�															�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �oObj:RollBack()  		   								    �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/
Method Rollback() class RHPeriodo

	::cFilRCH	:= ::cAntFilRCH
	::cPeriodo	:= ::cAntPeriodo
	::cNumPagto	:= ::cAntNumPagto	
	
	::dDataIni	:= ::dAntDataIni
	::dDataFim	:= ::dAntDataFim 
	::dDtFecha	:= ::dAntDtFecha 	
	
	::cAno		:= ::cAntAno
	::cMes		:= ::cAntMes
		
	::lFechado	:= ::lAntFechado
	::lAberto	:= ::lAntAberto
	::lFound	:= ::lAntFound 
	::nRecno	:= ::nAntRecno	
	
	IF ::lFound
		RCH->(MsGoto(::nRecno))
	Else	
		RCH->(DbGoBottom())
    Endif                
    
Return(Nil)	

/*/
�����������������������������������������������������������������������Ŀ
�Funcao    �fPosAlias     � Autor � Mauricio MR       � Data �26/11/2007�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para Posicionar em determinado Registro de um Alias  �
�����������������������������������������������������������������������Ĵ
�Par�metros�Ver parametros  											�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Ver parametros  		   								    �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/                     
Static Function fPosAlias(;
 							cAlias		,; //Alias para a ser pesquisado
 							nIndex		,; //Numero do indice para pesquisa
 							cKey		,; //Chave para busca do registro
 							cFiltro		,; //Condicao de filtro do registro (OPCIONAL)
 							lRePosiciona,; //.T. reposiciona para o registro anterior a pesquisa (OPCIONAL)
 							nPosicao	 ; //Retrocede n registros a partir da posicao do alias
 						)
    
	Local aArea			:= GetArea()
	Local aRCHArea		:= RCH->(GetArea())
	Local bWhile		:= {}

    DEFAULT cFiltro		:= "Eval({||.T.})"
	DEFAULT lRePosiciona:= .F.
	DEFAULT nPosicao	:= 1
	
	
	
	If ( nPosicao >= 0 )
		bWhile := {|| !Eof() }
	Else
		bWhile := {|| !Bof() }	
	EndIf
	(cAlias)->(dbSetOrder(nIndex))
	(cAlias)->(MsSeek(cKey))
	
	WHILE 	(cAlias)->(Eval(bWhile))
		IF (cAlias)->(&(cFiltro) == .T.)
			EXIT
		ENDIF
		(cAlias)->(dbSkip(nPosicao))
	ENDDO           
    
    IF lRePosiciona
		RestArea( aRCHArea )
		RestArea( aArea )
	Else
		IF Alltrim(Upper(aArea[1])) <> Alltrim(Upper(aRCHArea[1]))
			RestArea( aArea )
		Endif	
	Endif	
	
Return(Nil)

/*/
�����������������������������������������������������������������������Ŀ
�Funcao    �fbPerUltFech  � Autor � Mauricio MR       � Data �12/06/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Funcao para filtrar ultimo registro fechado					�
�����������������������������������������������������������������������Ĵ
�Par�metros�Ver parametros  											�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Ver parametros  		   								    �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�������������������������������������������������������������������������/*/    
Static Function fbPerUltFech(cKey)                           
Local lRet := .F.

//Armazena o ultimo registro lido para o roteiro pesquisado
If (RCH_FILIAL+RCH_PROCES+RCH_ROTEIR) == ( cKey )
	If !EMPTY(RCH_DTFECH)
		nLastRec := RCH->(Recno())
		lRet 	 := .T.
	EndIf
   //Continua a busca se a data de fechamento permanece vazia (periodo aberto) ou
   //finaliza a pesquisa se o periodo for fechado
Else                                             
   // Se houver quebra de chave 
   RCH->(MsGoto(nLastRec))
   lRet	:= .T.
Endif                     

Return (lRet)

//01 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+RCH_ROTEIR" )))
//02 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
//03 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_PER+RCH_NUMPAG+DTOS(RCH_DTFECH)+RCH_ROTEIR" )))
//04 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PER+RCH_NUMPAG" )))
//05 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+DTOS(RCH_DTFECH)+RCH_PER+RCH_NUMPAG" )))
//06 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_ANO+RCH_MES" )))
//07 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_ANO+RCH_MES" )))
//08 RCH->(DbSetOrder( RetOrder( "RCH", "RCH_FILIAL+RCH_PROCES+RCH_ROTEIR+RCH_PERSEL" )))



