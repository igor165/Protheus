#include "protheus.ch"
/*
  Esta funcao foi criada para que seja possivel visualizar a data deste
  fonte no inspetor de objetos, pois nao eh possivel fazer isso se nao
  houver nenhuma FUNCTION no fonte.
*/
FUNCTION EFDCBLOCOI();RETURN
//-------------------------------------------------------------------
/*/{Protheus.doc} EFDCBLOCOI()
@description Classe que terá as informações específicas para geração dos 
			   registros do bloco I no SPED Contribuições. Esta classe não herda
			   as propriedades da classe NOTAEFD, pois não possuem informações
			   em comum, neste bloco não são tratadas informações de notas,
			   são totais de valores das instituições Financeiras. Este
			   bloco tem relação somente com o bloco M da apuração.			   

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
CLASS EFDCBLOCOI FROM NOTAEFD

//-----------------------------------------------------
//ATRIBUTOS DA CLASSE
//-----------------------------------------------------
Data cCst			as String		READONLY	//CST de pis e cofins.
Data cInfComp		as String		READONLY	//Informação complementar do registro
Data cNumCpo		as String		READONLY	//Número do campo
Data cCod7112		as String		READONLY	//Código da tabela 711 ou da tabela 712  
Data cCod7134		as String		READONLY	//Código da tabela 713 ou da tabela 714
Data cCodCta		as string		READONLY	//Código da conta contábil
Data nVlRec		as Integer		READONLY	//Valor total da receita/faturamento 
Data nExGer		as Integer		READONLY	//valor das exclusões gerais
Data nExEsp		as Integer		READONLY	//valor das exclusões específicas
Data nBasPis		as Integer		READONLY	//base de cálculo de PIS
Data nBasCof		as Integer		READONLY	//base de cálculo da COFINS
Data nAlqPis		as Integer		READONLY	//Alíquota do PIS
Data nAlqCof		as Integer		READONLY	//Alíquota da COFINS
Data nValPis		as Integer		READONLY	//Valor de PIS
Data nValCof		as Integer		READONLY	//Valor da COFINS
Data nVlComp		as Integer		READONLY	//Valor da composição das receitas, deduções ou exclusões das tabelas 711/712
Data nVlDet		as Integer		READONLY	//Valor do detalhamento das receitas, deduções ou exclusões das tabelas 713/714

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO I
//-------------------------------------------------------------
Data aRegI100		as Array		READONLY		
Data aRegI200		as Array		READONLY		
Data aRegI300		as Array		READONLY
Data aRegI199		as Array		READONLY
Data aRegI299		as Array		READONLY
Data aRegI399		as Array		READONLY
Data aRegI001		as Array		READONLY	
Data aRegI990		as Array		READONLY			
	
//-------------------------------------------------------------
//MÉTODOS DA CLASSE
//-------------------------------------------------------------
Method New()
Method Clear()
Method AddI100()
Method AddI200()
Method AddI300()
Method AddProcRef(cReg)
Method AddI001(cIndMovto)
Method AddI990(nQtde)
Method clsI100 ()

Method setCst( cCst) 	
Method setInfComp( cInfComp) 	
Method setNumCpo( cNumCpo) 	
Method setCod7112( cCod7112) 	
Method setCod7134( cCod7134) 	
Method setCodCta( cCodCta) 	
Method setVlRec( nVlRec) 
Method setExGer( nExGer) 	
Method setExEsp( nExEsp) 	
Method setBasPis( nBasPis) 	
Method setBasCof( nBasCof) 	
Method setAlqPis( nAlqPis) 	
Method setAlqCof( nAlqCof) 	
Method setValPis( nValPis) 	
Method setValCof( nValCof) 	
Method setVlComp( nVlComp) 	
Method setVlDet( nVlDet)

Method getI100() 	 	
Method getI199()
Method getI200()
Method getI299()
Method getI300()
Method getI399()


ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe 

@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD New() Class EFDCBLOCOI
Self:cJob	:= '00'
Self:Clear()
Self:ClsNotaEfd()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Clear()
@description Método que inicializa as propriedades da classe

@author Erick G. Dias
@since 24/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
Method Clear() Class EFDCBLOCOI

Self:cCst			:= ''	//CST de pis e cofins.
Self:cInfComp		:= ''	//Informação complementar do registro
Self:cNumCpo		:= ''	//Número do campo
Self:cCod7112		:= ''	//Código da tabela 711 ou da tabela 712  
Self:cCod7134		:= ''	//Código da tabela 713 ou da tabela 714
Self:cCodCta		:= ''	//Código da conta contábil
Self:nVlRec		:= 0	//Valor total da receita/faturamento 
Self:nExGer		:= 0	//valor das exclusões gerais
Self:nExEsp		:= 0	//valor das exclusões específicas
Self:nBasPis		:= 0	//base de cálculo de PIS
Self:nBasCof		:= 0	//base de cálculo da COFINS
Self:nAlqPis		:= 0	//Alíquota do PIS
Self:nAlqCof		:= 0	//Alíquota da COFINS
Self:nValPis		:= 0	//Valor de PIS
Self:nValCof		:= 0	//Valor da COFINS
Self:nVlComp		:= 0	//Valor da composição das receitas, deduções ou exclusões das tabelas 711/712
Self:nVlDet		:= 0	//Valor do detalhamento das receitas, deduções ou exclusões das tabelas 713/714

//-------------------------------------------------------------
//ARRAY DOS REGISTROS DO BLOCO I
//-------------------------------------------------------------
Self:aRegI100		:= {}		
Self:aRegI200		:= {}		
Self:aRegI300		:= {}
Self:aRegI199		:= {}
Self:aRegI299		:= {}
Self:aRegI399		:= {}
Self:aRegI001		:= {}
Self:aRegI990		:= {}

Return


Method setCst( cCst) Class EFDCBLOCOI
	Self:cCst := cCst
Return
Method setInfComp( cInfComp) Class EFDCBLOCOI
	Self:cInfComp := cInfComp
Return
Method setNumCpo( cNumCpo) Class EFDCBLOCOI
	Self:cNumCpo := cNumCpo
Return
Method setCod7112( cCod7112) Class EFDCBLOCOI
	Self:cCod7112 := cCod7112
Return
Method setCod7134( cCod7134) Class EFDCBLOCOI
	Self:cCod7134 := cCod7134
Return
Method setCodCta( cCodCta) Class EFDCBLOCOI
	Self:cCodCta := cCodCta
Return
Method setVlRec( nVlRec) Class EFDCBLOCOI
	Self:nVlRec := nVlRec
Return
Method setExGer( nExGer) Class EFDCBLOCOI
	Self:nExGer := nExGer
Return
Method setExEsp( nExEsp) Class EFDCBLOCOI
	Self:nExEsp := nExEsp
Return
Method setBasPis( nBasPis) Class EFDCBLOCOI
	Self:nBasPis := nBasPis
Return
Method setBasCof( nBasCof) Class EFDCBLOCOI
	Self:nBasCof := nBasCof
Return
Method setAlqPis( nAlqPis) Class EFDCBLOCOI
	Self:nAlqPis := nAlqPis
Return
Method setAlqCof( nAlqCof) Class EFDCBLOCOI
	Self:nAlqCof := nAlqCof
Return
Method setValPis( nValPis) Class EFDCBLOCOI
	Self:nValPis := nValPis
Return
Method setValCof( nValCof) Class EFDCBLOCOI
	Self:nValCof := nValCof
Return
Method setVlComp( nVlComp) Class EFDCBLOCOI
	Self:nVlComp := nVlComp
Return
Method setVlDet( nVlDet) Class EFDCBLOCOI
	Self:nVlDet := nVlDet
Return

Method getI100() Class EFDCBLOCOI
Return	Self:aRegI100

Method getI199() Class EFDCBLOCOI
Return	Self:aRegI199

Method getI200() Class EFDCBLOCOI
Return	Self:aRegI200

Method getI299() Class EFDCBLOCOI
Return	Self:aRegI299

Method getI300() Class EFDCBLOCOI
Return	Self:aRegI300

Method getI399() Class EFDCBLOCOI
Return	Self:aRegI399

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI100()
@description Método que inclui novo registro I100. Neste registro teremos
			   a consolidação de valores de PIS e COFINS do período
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI100() Class EFDCBLOCOI

Local nPos	:= 0

nPos :=AScan(Self:aRegI100, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;
									   aX[4]==Self:cCst 		.AND. ;
									   aX[8]==Self:nAlqPis 	.AND.;
									   aX[11]==Self:nAlqCof .AND.;
									   aX[13]==Self:cInfComp})

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'I100')
	aAdd(Self:aRegI100, {})
	nPos	:=	Len (Self:aRegI100)	
	aAdd (Self:aRegI100[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aRegI100[nPos], "I100")	  			//01 - REG      
	aAdd (Self:aRegI100[nPos], Self:nVlRec)	 	//02 - VL_REC   
	aAdd (Self:aRegI100[nPos], Self:cCst)		  	//03 - CST_PIS_COFINS
	aAdd (Self:aRegI100[nPos], Self:nExGer)	 	//04 - VL_TOT_DED_GER
	aAdd (Self:aRegI100[nPos], Self:nExEsp)	 	//05 - VL_TOT_DED_ESP
	aAdd (Self:aRegI100[nPos], Self:nBasPis)	 	//06 - VL_BC_PIS
	aAdd (Self:aRegI100[nPos], Self:nAlqPis)	 	//07 - ALIQ_PIS
	aAdd (Self:aRegI100[nPos], Self:nValPis)	 	//08 - VL_PIS
	aAdd (Self:aRegI100[nPos], Self:nBasCof)	 	//09 - VL_BC_COFINS
	aAdd (Self:aRegI100[nPos], Self:nAlqCof)	 	//10 - ALIQ_COFINS
	aAdd (Self:aRegI100[nPos], Self:nValCof)	 	//11 - VL_COFINS
	aAdd (Self:aRegI100[nPos], Self:cInfComp)	 	//12 - INFO_COMPL
Else
	Self:aRegI100[nPos][3]  += Self:nVlRec			//02 - VL_REC
	Self:aRegI100[nPos][5]  += Self:nExGer			//04 - VL_TOT_DED_GER
	Self:aRegI100[nPos][6]  += Self:nExEsp			//05 - VL_TOT_DED_ESP
	Self:aRegI100[nPos][7]  += Self:nBasPis		//06 - VL_BC_PIS
	Self:aRegI100[nPos][9]  += Self:nValPis		//08 - VL_PIS 
	Self:aRegI100[nPos][10]  += Self:nBasCof		//09 - VL_BC_COFINS	
	Self:aRegI100[nPos][12] += Self:nValCof		//11 - VL_COFINS
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI200()
@description Método que inclui novo registro I200. Serão demonstrados os
			  detalhamentos de receita, deduções e exclusões. Este registro 
			  é filho do registro I100.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI200() Class EFDCBLOCOI

Local nPos	:= 0

nPos :=AScan(Self:aRegI200, {|aX|  SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;  
										aX[3]==Self:cNumCpo .AND. ;
										aX[4]==Self:cCod7112 .AND. ;
										aX[6]==Self:cCodCta .AND.;
										aX[7]==Self:cInfComp})

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'I200')
	aAdd(Self:aRegI200, {})
	nPos	:=	Len (Self:aRegI200)	
	aAdd (Self:aRegI200[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aRegI200[nPos], "I200")	  			//01 - REG      
	aAdd (Self:aRegI200[nPos], Self:cNumCpo)	  	//02 - NUM_CAMPO   
	aAdd (Self:aRegI200[nPos], Self:cCod7112)	 	//03 - COD_DET
	aAdd (Self:aRegI200[nPos], Self:nVlComp)	  	//04 - DET_VALOR
	aAdd (Self:aRegI200[nPos], Self:cCodCta)	  	//05 - COD_CTA
	aAdd (Self:aRegI200[nPos], Self:cInfComp)  	//06 - INFO_COMPL	
Else
	Self:aRegI200[nPos][5] += Self:nVlComp			//04 - DET_VALOR
EndIF

Return Self:aRegI200[nPos][1]

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI300()
@description Método que inclui novo registro I300. Este registro é complemento
			   do detalhamento das receitas, exclusões e deduções. Este registro
			   é filho do registro I200.
@author Erick G. Dias
@since 22/10/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI300() Class EFDCBLOCOI

Local nPos	:= 0

nPos :=AScan(Self:aRegI300, {|aX| SubStr(aX[1],1,Len(Self:cRelac ))== Self:cRelac .AND. ;  
									   aX[3]==Self:cCod7134 .AND. ;
									   aX[5]==Self:cCodCta  .AND. ;
									   aX[6]==Self:cInfComp })

If nPos == 0
	Self:cGrupoReg		:= FSA008SReg(@Self:aNumeracao,Self:cRelac, 'I300')
	aAdd(Self:aRegI300, {})
	nPos	:=	Len (Self:aRegI300)	
	aAdd (Self:aRegI300[nPos], Self:cGrupoReg)	//RELACIONAMENTO
	aAdd (Self:aRegI300[nPos], "I300")	  			//01 - REG      
	aAdd (Self:aRegI300[nPos], Self:cCod7134)	 	//02 - COD_COMP   
	aAdd (Self:aRegI300[nPos], Self:nVlDet)		//03 - DET_VALOR
	aAdd (Self:aRegI300[nPos], Self:cCodCta)	 	//04 - COD_CTA
	aAdd (Self:aRegI300[nPos], Self:cInfComp)	 	//05 - INFO_COMPL	
Else
	Self:aRegI300[nPos][4] += Self:nVlDet			//03 - DET_VALOR
EndIF

Return Self:aRegI300[nPos][1]

//-------------------------------------------------------------------
/*/{Protheus.doc} AddProcRef()
@description Método que inclui novo registros I199, I299 e  I399.
			   Todos relacionados com processo referenciado.			   			  
@author Erick G. Dias
@since14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddProcRef(cReg) Class EFDCBLOCOI

Do Case
	Case cReg == 'I199'	
		Self:ProcRef('I199',@Self:aRegI199)
	Case cReg == 'I299'
		Self:ProcRef('I299',@Self:aRegI299)
	Case cReg == 'I399'
		Self:ProcRef('I399',@Self:aRegI399)	
EndCase

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI001()
@description Método para geração do registro de abertura do bloco
@param cIndMovto,String,Indicador de movimento de abertura do bloco
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI001(cIndMovto) Class EFDCBLOCOI

Self:AbreBloco('I001',@Self:aRegI001,cIndMovto)

Return Self:aRegI001

//-------------------------------------------------------------------
/*/{Protheus.doc} AddI990()
@description Método para geração do registro de encerramento do bloco
@param nQtde,Integer,Número de quantidade de linhas
@author Erick G. Dias
@since 14/11/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD AddI990(nQtde) Class EFDCBLOCOI

Self:FechaBloco('I990',@Self:aRegI990, nQtde) 

Return Self:aRegI990

//-------------------------------------------------------------------
/*/{Protheus.doc} clsI100()
@description Método que limpa variáveis do F100
@author Erick G. Dias
@since 05/12/2014
@version 11.90
/*/
//-------------------------------------------------------------------
METHOD clsI100() Class EFDCBLOCOI

Self:Clear(.F.)
Self:ClsNotaEfd(.F.)


Return
 