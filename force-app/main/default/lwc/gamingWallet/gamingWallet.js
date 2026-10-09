import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getGamingWallet from '@salesforce/apex/MemberEngagementSummaryController.getGamingWallet';

export default class GamingWallet extends LightningElement {
    @api member;
    walletCurrencies = [];
    walletBalanceTime = '';
    isWalletModalOpen = false;
    isRefreshing = false;
    showRefreshSuccess = false;
    showInfo = false;
    walletWireResult;
    refreshTimeout;

    @wire(getGamingWallet, { memberId: '$member.Id' })
    wiredGamingWallet(result) {
        this.walletWireResult = result;
        const { data, error } = result;
        if (data) {
            this.walletCurrencies = data.map((item, index) => {return {...item,
                    formattedBalance: new Intl.NumberFormat('en-US').format(item.pointsBalance || 0),
                    cardClass: `currencyCard currencyCard${(index % 4) + 1}`
                };
            });
            this.setWalletBalanceTime();
        } else if (error) this.walletCurrencies = [];
    }

    get visibleWalletCurrencies() {
        return this.walletCurrencies.slice(0, 4);
    }

    get refreshButtonClass() {
        return this.isRefreshing ? 'refreshButton refreshing' : 'refreshButton';
    }

    setWalletBalanceTime() {
        this.walletBalanceTime = new Intl.DateTimeFormat('en-GB', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit', hour12: true}).format(new Date());
    }

    handleInfoClick() {
        this.showInfo = !this.showInfo;
    }

    handleViewAll() {
        if (this.walletCurrencies.length > 0) this.isWalletModalOpen = true;
    }

    handleCloseModal() {
        this.isWalletModalOpen = false;
    }

    async handleRefresh() {
        if (this.isRefreshing || !this.walletWireResult) return;
        this.isRefreshing = true;
        this.showRefreshSuccess = false;
        try {
            await refreshApex(this.walletWireResult);
            this.showRefreshSuccess = true;
            clearTimeout(this.refreshTimeout);
            this.refreshTimeout = setTimeout(() => {this.showRefreshSuccess = false;}, 3000);
        } catch (error) {
            console.error('Gaming Wallet Refresh Error:', JSON.stringify(error));
        } finally {
            this.isRefreshing = false;
        }
    }

    disconnectedCallback() {
        clearTimeout(this.refreshTimeout);
    }
}