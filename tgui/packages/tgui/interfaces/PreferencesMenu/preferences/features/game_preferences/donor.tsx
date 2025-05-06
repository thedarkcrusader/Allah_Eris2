import { CheckboxInput, Feature, FeatureChoicedServerData, FeatureToggle, FeatureDropdownInput, FeatureValueProps } from "../base";
import { BooleanLike } from "common/react";
import { useBackend } from "../../../../../backend";
import { PreferencesMenuData } from "../../../data";

export const donor_hat: Feature<string> = {
  name: "Donor hat",
  category: "DONATOR",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const donor_item: Feature<string> = {
  name: "Donor item",
  category: "DONATOR",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const donor_plush: Feature<string> = {
  name: "Donor plush",
  category: "DONATOR",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const borg_hat: FeatureToggle = {
  name: "Equip borg hat",
  category: "DONATOR",
  description: "When enabled, you will equip your selected donor hat when playing cyborg.",
  component: (
    props: FeatureValueProps<BooleanLike, boolean>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<CheckboxInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const donor_pda: Feature<string> = {
  name: "Donor PDA",
  category: "DONATOR",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const purrbation: Feature<string> = {
  name: "Purrbation",
  category: "DONATOR",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};

export const donor_eorg: Feature<string> = {
  name: "End-Round Item",
  category: "DONATOR",
  description: "Choose one item from the uplink to have spawned on you when the round ends.",
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
    context,
  ) => {
    const { data } = useBackend<PreferencesMenuData>(context);

    return (<FeatureDropdownInput
      {...props}
      disabled={(data.content_unlocked & 2) === 0}
    />);
  },
};
