#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MT120BRW Autor � Henrique Magalhaes   � Data � 28.03.2016�  ��
�������������������������������������������������������������������������Ĵ��
��� Descri��o � Adicionar rotinas ao menu de Compras                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �  Usado para campos especicifos da Vista Alegre              ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*   
LOCALIZA��O : Function MATA120 - Fun��o do Pedido de Compras e Autoriza��o de Entrega.
EM QUE PONTO : Ap�s a montagem do Filtro da tabela SC7 e antes da execu��o da Mbrowse do PC, utilizado para adicionar mais op��es no aRotina.

*/  


User Function MT120BRW()
//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa��o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     
//AAdd( aRotina, { 'Documento', 'MsDocument('SC7', SC7->(recno()), 4)', 0, 4 } )
AAdd( aRotina, { 'Antecipacao'		, 'u_VAFINA02("P")', 0, 6 } )
AAdd( aRotina, { 'Gerar Titulo'		, 'u_VAFINA03("P")', 0, 6 } )
AAdd( aRotina, { 'Gerar Comissao'	, 'u_VACOMA03("P")', 0, 6 } )
//AAdd( aRotina, { 'Relatorio'	    , 'U_VACOMR11()'   , 0, 1 } )

Return

